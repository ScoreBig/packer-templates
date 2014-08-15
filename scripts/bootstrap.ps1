
# do stuff (install any other needed software, etc)

# we bootstrap salt as part of user data during VM creation rather than here
# that way we get the latest salt-minion and it can be fed the correct minion/master name

# most other client software is installed as salt states, so this is empty