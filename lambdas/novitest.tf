ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github_scaramanga -C "github-scaramanga"

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github_helingen -C "github-helingen"


ssh -T git@github-scaramanga
ssh -T git@github-helingen


git@github-scaramanga:Scaramanga82/aws-delux-lab.git



git clone git@github-clientA:ORG_A/repo-a.git projectA
git clone git@github-clientB:ORG_B/repo-b.git projectB



git config user.name "Scaramanga82"
git config user.email "kanazirmilos@gmail.com"


git config user.name "Helingen82"
git config user.email "kanazirmilos82@gmail.com"