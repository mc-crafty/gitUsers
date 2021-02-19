#                   ::::::::
#         :+:      :+:    :+:
#    +++++++++++  +:+         +++++
#       +:+      +#+         +#  +#
#      +#+      +#+         +#
#     #+#      #+#     +#  +#  +#
#    ###       ########+   ####+
#
# tCc|MC_Crafty
# mc_crafty@gmx.com
#
# To install, source this file from .bashrc


gitUsers_file=~/.gitUsers

if [ ! -f $gitUsers_file ]; then
    touch $gitUsers_file
fi


# create a user
gitUsers_create() {

    user_name=$1
    user_email=$2

    if [ -n "$user_name" ]; then
        user="$user_email""¶""$user_name" # Store the user as email¶name
        user_check=`grep "¶$user_name$" "$gitUsers_file"`
        if [ -z "$user_check" ]; then
            echo $user >> $gitUsers_file
            echo "Git user '$user_name' saved"
        else
            echo "Git user '$user_name' already exists"
        fi
    else
        echo "Invalid name: '$user_name'"
    fi
}

# show current Users
gitUsers_show() {
    echo "Git Users:"
    cat $gitUsers_file | awk '{ printf "\n%s\n%s\n",$2,$1}' FS=¶
}

# delete a user
gitUsers_delete() {

    user_name=$1

    if [ -n "$user_name" ]; then
        user_check=`grep "¶$user_name$" "$gitUsers_file"`
        if [ -z "$user_check" ]; then
            echo "Can not find: '$user_name'"
        else
            user=`grep -v "¶$user_name$" "$gitUsers_file" | awk '{printf "%s¶%s╩",$1,$2}' FS=¶`
            if [ -n "$user" ]; then
                rm $gitUsers_file
                echo $user | tr '╩' '\n' | awk 'NF > 0' >> $gitUsers_file
                echo "Git user '$user_name' deleted"
            else
                # if we only have one git user and we're deleting it, grep -v returns nothing
                # instead just remove the file and touch it clean
                rm $gitUsers_file
                touch $gitUsers_file
                echo "Git user '$user_name' deleted"
            fi
        fi
    else
        echo "Invalid name: '$user_name'"
    fi
}

# change to a specified user
gitUsers_change() {

    user_name=$1

    user=`grep "¶$user_name$" "$gitUsers_file"`

    if [ -n "$user" ]; then
        current_user_name=`git config --get user.name`
        if [ ! "$current_user_name" == "$user_name" ]; then
            user_email=`echo "$user" | awk '{printf "%s",$1}' FS=¶`
            echo "Setting Git user to values for $user_name"
            git config --global user.name "$user_name"
            git config --global user.email $user_email
        else
            echo "Git user '$current_user_name' is already set"
        fi
    else
        echo "Invalid name: '$user_name'"
    fi
}

# show current user from git config
gitUsers_show_current() {
    echo "Current Git user:"
    echo
    git config --get user.name
    git config --get user.email
}

# create a git user entry from the current git config
gitUsers_create_current() {

    user_name_config="`git config --get user.name`"
    user_email_config="`git config --get user.email`"

    gitUsers_create "$user_name_config" "$user_email_config"
}


# TabComplete - List all Users, grep for match
_tabCompleteGitUsers(){
    cat $gitUsers_file | awk '{printf "%s\n",$2}' FS=¶ | grep "$2.*"
}
complete -C _tabCompleteGitUsers -o default gitUsers_change
