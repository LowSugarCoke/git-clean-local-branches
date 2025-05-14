@echo off
setlocal enabledelayedexpansion

:: Update the list of remote branches
echo Fetching and pruning remote branches...
git fetch --prune

:: List all local branches
echo Listing all local branches...
set "local_branches="
for /f "delims=" %%a in ('git branch --format="%%(refname:short)"') do (
    set "local_branches=!local_branches! %%a"
)

:: List all remote branches (excluding origin/HEAD)
echo Listing all remote branches...
set "remote_branches="
for /f "tokens=*" %%a in ('git branch -r ^| findstr /V "origin/HEAD"') do (
    set "branch_name=%%a"
    set "branch_name=!branch_name:origin/=!"
    set "remote_branches=!remote_branches! !branch_name!"
)

:: Delete local branches that do not exist on the remote
echo Checking and deleting local branches not on remote...
for %%a in (%local_branches%) do (
    echo %remote_branches% | find "%%a" >nul
    if errorlevel 1 (
        echo Local branch %%a not found on remote. Deleting...
        git branch -d %%a 2>nul || git branch -D %%a
    )
)

echo Cleanup completed! Only unused local branches have been deleted.
pause
