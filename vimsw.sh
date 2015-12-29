#!/bin/bash

VERSION="0.0.1"

VIMSW_DIR="$HOME/.vimsw"
VIMSW_CONFIG_FILE="$VIMSW_DIR/config"
VIMSW_SETTING_DIR="$VIMSW_DIR/settings"
VIMSW_VIMRC_PREFIX="$VIMSW_SETTING_DIR/vimrc_"	# .vimrc_name
VIMSW_VIM_PREFIX="$VIMSW_SETTING_DIR/vim_"		# .vim_name
ORG_VIMRC="$HOME/.vimrc"
ORG_VIM="$HOME/.vim"

#installed : 1(installed), 0(uninstalled)
#setting_num : # of settings.
#settings : array of settings. settings[id] = setting name.
#current_id : id of current setting.
init() {
	# 1. determine whether installed or not.
	#	1-1. return 1 if not installed.
	# 2. read VIMSW_CONFIG_FILE.
	#	2-1. get # of settings.
	#	2-2. get id of current setting.
	if [[ ! -d "$VIMSW_DIR" || ! -d "$VIMSW_SETTING_DIR" ||
		! -f "$VIMSW_CONFIG_FILE" ]]; then
		# if not installed
		installed=0
	else
		# if installed
		installed=1
		setting_num=$(sed -n '1p' "$VIMSW_CONFIG_FILE")
		idx=0
		sed -n '1,$p' "$VIMSW_CONFIG_FILE" | 
		while read name; do
			settings[$idx]="$name"
			idx=`expr $idx + 1`
		done
	fi
	echo -n "init() finished. installed : $installed, "
	echo "setting_num : $setting_num"
	return 0
}

install() {
	# 1. return 1 if installed.
	# 2. install.
	if [ "$installed" = "1" ]; then
		# if installed
		return 1
	fi
	if [ -e "$VIMSW_DIR" ]; then
		# if directory exists
		return 1
	fi
	mkdir "$VIMSW_DIR" || return 1
	mkdir "$VIMSW_SETTING_DIR" || return 1
	echo 0 > "$VIMSW_CONFIG_FILE" || return 1

	return 0
}

uninstall() {
	# not supported.
	# hard to determine policy.
	return 1
}

# $1 : name
check_name() {
	for name in "${settings[@]}"
	do
		if [ "$name" = "$1" ]; then
			return 1
		fi
	done
	return 0
}

# $1 : name of setting.
reg_setting() {
	# 1. register setting.
	# 2. set current id to id of new setting.
	if [ check_name ]; then
		# name is duplicated.
		return 1
	fi
	if [ -e "$ORG_VIMRC" ]; then
		cp -f "$ORG_VIMRC" "$VIMSW_VIMRC_PREFIX$1"
	fi
	if [ -e "$ORG_VIM" ]; then
		cp -rf "$ORG_VIM" "$VIMSW_VIM_PREFIX$1"
	fi
	settings[$setting_num]="$1"
	setting_num=`expr $setting_num + 1`
	sed -i '1s/^.*$/'"$setting_num"'/' "$VIMSW_CONFIG_FILE"
	echo "$1" >> "$VIMSW_CONFIG_FILE"
	return 0
}

# $1 : id of target setting.
del_setting() {
	# 1. check validation. return 1 if invalid.
	#	1-1. $1 is in range?
	#	1-2. $1 != id of current setting?
	# 2. do deleting!
	return 0
}

upd_setting() {
	# 1. check validation. return 1 if invalid.
	#	1-1. id of current setting != -1? (-1 means not registed setting)
	# 2. do updating!
	return 0
}

# $1 : id of target setting.
switch() {
	# 1. check validation. return 1 if invalid.
	#	1-1. $1 is in range?
	# 2. do switching!
	return 0
}

# $1 : name of output variable.
# $2 : name of target setting.
name2id() {
	# return 1 if invalid name
	return 0
}

execute() {
	if [ $# -eq 0 ]; then
		show_usage
		return 1
	fi
	echo "execute() starts"
	while [[ $# > 0 ]]
	do
		local key="$1"

		case $key in
			install|ins)
				install || return 1
				;;
			uninstall|unins)
				uninstall || return 1
				;;
			register|reg|r)
				local id
				reg_setting "$2" || return 1
				shift
				;;
			delete|del|d)
				local id
				name2id id "$2"
				del_setting "$id" || return 1
				shift
				;;
			update|upd|u)
				upd_setting "$cur_id" || return 1
				;;
			switch|swit|s)
				local id
				name2id id "$2"
				switch "$id" || return 1
				shift # past argument
				;;
			*)
				# unknown option
				show_usage
				return 1
				;;
		esac
		shift # past argument or value
	done
	return 0
}

show_usage() {
	echo "
	[Usage] haaam...
	"
}

main() {
	init || return 1
	execute $@ || return 1
}

main $@ || exit 1
exit 0
