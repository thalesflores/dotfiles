import type { Register } from 'claude-code'

const ASK = 'Ask the user; they can run it themselves with `! <command>`.'
const AI_MENTION = /Co-Authored-By:\s*Claude|Generated with \[?Claude/i
const UNSIGNED = /--no-gpg-sign|commit\.gpgsign=(false|0)/
const PUSH = /\bgit\b(?:\s+-C\s+\S+)*\s+push\b([^;&|]*)/
const DIR = /\bgit\s+-C\s+("[^"]+"|'[^']+'|\S+)|(?:^|&&|;)\s*cd\s+("[^"]+"|'[^']+'|\S+)/

export const pushTargets = (args: string, current: string): string[] | 'all' => {
  const words = args.replace(/(^|\s)\d+(?=[<>])/g, '$1').replace(/[<>]+\s*\S*/g, '')
  const tokens = words.trim().split(/\s+/).filter(Boolean)
  if (tokens.some(t => t === '--all' || t === '--mirror')) return 'all'
  const refspecs = tokens.filter(t => !t.startsWith('-')).slice(1)
  if (refspecs.length === 0) return [current]
  return refspecs.map(r => {
    const dst = r.replace(/^\+/, '').split(':').pop()!.replace(/^refs\/heads\//, '')
    return dst === 'HEAD' || dst === '' ? current : dst
  })
}

export const register: Register = on => {
  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const c = e.command
    const deny = (why: string) => ({ deny: `git-guard: ${why}. ${ASK}` })

    if (/\bfilter-branch\b/.test(c)) return deny('filter-branch strips SSH signatures')
    if (/\b(git|gh)\b/.test(c) && AI_MENTION.test(c)) return deny('no AI attribution in commits or PRs')
    if (/\bgit\b.*\bcommit\b/.test(c) && UNSIGNED.test(c)) return deny('commits must be signed')

    const push = PUSH.exec(c)
    if (!push) return next(e)

    const m = DIR.exec(c)
    const dir = m?.[1] ?? m?.[2] ?? '.'
    const git = (...args: string[]) =>
      $.process.run(['sh', '-c', `cd ${dir} && git "$@"`, 'sh', ...args]).then(r => ({ ok: r.exitCode === 0, out: r.stdout.trim() }))

    const current = (await git('rev-parse', '--abbrev-ref', 'HEAD')).out
    const targets = pushTargets(push[1], current)
    if (targets === 'all') return deny('--all/--mirror pushes every branch')
    if (targets.some(b => b === 'main' || b === 'master')) return deny('never push to main/master')

    const me = await $.session.id()
    for (const branch of targets) {
      const owner = await git('config', '--get', `branch.${branch}.claude-session`)
      if (owner.ok && owner.out !== me) return deny(`${branch} is claimed by another Claude session (${owner.out})`)
    }
    for (const branch of targets) await git('config', `branch.${branch}.claude-session`, me)

    return next({ ...e, command: c.replace(/(\bpush\b[^;&|]*?)\s(--force|-f)(?=\s|$)/, '$1 --force-with-lease') })
  })
}
