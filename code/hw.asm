:main: # define main label
%string "Hello world!" xA 0 42% # define string data label ("Hello world!", followed by a newline char, followed by a null char, followed by the number "42")
mov a0 string # store the address of string into the first argument register
cal print # call the predefined print function
add a0 14 # add 14 to the a0 register
mov g0 1?a0 # put the byte at the address stored in a0 in the return register
ret # return (end the program)
