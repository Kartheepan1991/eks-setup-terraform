# Git Workflow Quick Reference

## Daily Development Commands
```bash
# Check current branch
git branch --show-current

# View all branches
git branch -a

# Switch branches if needed
git checkout feature/eks-infrastructure-setup
git checkout main

# View changes
git status
git diff

# Commit workflow
git add .                                    # Stage all changes
git add specific-file.tf                     # Stage specific file
git commit -m "feat: add cluster autoscaler" # Commit with message
git push origin feature/eks-infrastructure-setup

# View commit history
git log --oneline
git log --oneline --graph --all
```

## When Ready to Merge to Main
```bash
# 1. Switch to main and update
git checkout main
git pull origin main

# 2. Merge feature branch
git merge feature/eks-infrastructure-setup

# 3. Push updated main
git push origin main

# 4. Optional: Delete feature branch after merge
git branch -d feature/eks-infrastructure-setup
git push origin --delete feature/eks-infrastructure-setup
```

## Useful Git Tips
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# View differences between branches
git diff main..feature/eks-infrastructure-setup

# Create new feature branch from current
git checkout -b feature/new-feature-name

# Sync feature branch with latest main
git checkout feature/eks-infrastructure-setup
git merge main
```
