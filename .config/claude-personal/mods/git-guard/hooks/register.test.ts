import { test, expect } from 'claude-code/testing'
import { pushTargets } from './register'

test('push targets', () => {
  expect(pushTargets('', 'feat')).toEqual(['feat'])
  expect(pushTargets('-u origin feat', 'x')).toEqual(['feat'])
  expect(pushTargets('origin HEAD:other', 'feat')).toEqual(['other'])
  expect(pushTargets('origin +refs/heads/a:refs/heads/b', 'x')).toEqual(['b'])
  expect(pushTargets('--force-with-lease origin HEAD', 'feat')).toEqual(['feat'])
  expect(pushTargets('origin --all', 'feat')).toBe('all')
  expect(pushTargets('-u origin feat 2>', 'x')).toEqual(['feat'])
  expect(pushTargets('origin feat > out.txt', 'x')).toEqual(['feat'])
  expect(pushTargets('origin feat2>/dev/null', 'x')).toEqual(['feat2'])
})

test('denies unsafe git commands, passes others', async ($, on) => {
  on('tool.call', { tool: 'Bash' }, () => ({ result: { stdout: 'ran', stderr: '', interrupted: false } }) as never)
  const run = (command: string) => $.tool.call({ tool: 'Bash', command } as never) as Promise<{ deny?: string; isError?: boolean; text?: string; result?: { stdout: string } }>

  for (const cmd of [
    'git filter-branch --env-filter x',
    'git commit --no-gpg-sign -m x',
    'git -c commit.gpgsign=false commit -m x',
    'git commit -m "x\n\nCo-Authored-By: Claude Opus <noreply@anthropic.com>"',
    'gh pr create --body "🤖 Generated with [Claude Code](https://claude.com/claude-code)"',
  ]) {
    const r = await run(cmd)
    expect(r.deny ?? (r.isError ? r.text : '')).toContain('git-guard')
  }
  expect((await run('git status')).result?.stdout).toBe('ran')
  expect((await run('git commit -m "fix: x"')).result?.stdout).toBe('ran')
})
