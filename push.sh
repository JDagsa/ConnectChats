#!/bin/bash

echo "Initiating push to GitHub."
echo "Staging changes..."
git add .
echo "Staged changes."
echo "Please enter your commit message."
read COMMIT
echo "Obtained message. Initiating commit..."
git commit -m "$COMMIT"
echo "Committed changes. Pushing to GitHub..."
git push origin master
echo "Pushed local changes to GitHub. Check at https://github.com/JDagsa/ConnectChats"

