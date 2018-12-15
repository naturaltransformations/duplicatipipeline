



# TODO: UNCOMMENT AND FIX THIS IF REQUIRED
# if [ -f ~/.config/duplicati-mirror-sync.sh ]; then
#     bash ~/.config/duplicati-mirror-sync.sh
# else
#     echo "Skipping CDN update"
# fi

echo "+ uploading to AWS" && upload_binaries_to_aws
echo "+ releasing to github" && release_to_github
echo "+ posting to forum" && post_to_forum

echo "+ updating changelog" && update_changelog
echo "+ updating git repo" && update_git_repo


