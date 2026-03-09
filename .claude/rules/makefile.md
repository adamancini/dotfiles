# Makefile Invocation

IMPORTANT: Environment variables go AFTER `make`, not before. The Bash permission `Bash(make:*)` uses prefix matching.

CORRECT: `make vm-3node CLUSTER_PREFIX=adamancini`
CORRECT: `make replicated-release CHANNEL=beta VERSION=1.2.3`
WRONG:   `CLUSTER_PREFIX=adamancini make vm-3node` (won't match Bash permissions, requires manual approval every time)
