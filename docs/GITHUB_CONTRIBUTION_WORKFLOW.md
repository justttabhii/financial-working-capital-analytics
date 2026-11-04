# GitHub contribution workflow

Goal: make frequent, authentic contributions while finishing the project quickly. Do not stretch the work just to fill the graph.

## First local commit (after extracting the ZIP)
1. Open PowerShell in this project folder.
2. Run `git init`.
3. Set the author identity only if this repository has not already been configured:
   - `git config user.name "YOUR GITHUB NAME"`
   - `git config user.email "THE EMAIL LINKED TO YOUR GITHUB ACCOUNT"`
4. Run `git add README.md .gitignore data docs python sql`.
5. Run `git commit -m "chore: add financial analytics starter dataset and scripts"`.
6. Open GitHub Desktop → File → Add Local Repository → select this project folder, then publish the repository to GitHub.

If Git says an author name/email is already configured correctly, do not change it unnecessarily. Never put passwords or access tokens into project files.

## Later commits
Commit and push after each working milestone, such as schema/database creation, passing data-quality checks, revenue analysis, receivables analysis, Python reconciliation, dashboard pages, and documentation. One to three meaningful commits in a work session is a practical target, but the work should determine the number.

The profile graph does not count every local commit automatically. Commits need to be pushed and meet GitHub's contribution rules; use an email associated with the GitHub account and a qualifying branch. Never create empty or backdated commits merely to manipulate the graph.
