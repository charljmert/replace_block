## Remove/Replace blocks of regex specified in a text file from files

e.g. to remove the following lines from a file:

file1.php

```php
    echo "code before";

    for ($i = 0; ($i < 10); $i++) {
        echo "this code is everywhere. I want to remove all of it from the code base";
    }

    echo "code after";
```

### 1. Create a file called code.txt and place the following in it

Note the empty lines just before and after the "for" and closing "}".
These lines will be removed as well.

code.txt

```php

    for ($i = 0; ($i < 10); $i++) {
        echo "this code is everywhere. I want to remove all of it from the code base";
    }

```

### 2. Run the following command on file1.php

```bash
# Replace only from file1.php
replace_block code.txt ./ --search "file1.php"

# Perform block replace on all php files in "/home/user/directory" recursively.
replace_block code.txt /home/user/directory --search "*.php"

# If you want to convert your code.txt to regex and save it to a regex file
replace_block code.txt --convert > code_regex.txt

# You can then use the above code_regex.txt directly using --raw-regex
replace_block code.txt /home/user/directory --search "*.php" --raw-regex

# You can also edit the code_regex.txt file to make your pattern more flexible
vim code_regex.txt
```

### You will end up with
file1.php

```php
    echo "code before";
    echo "code after";
```

## Setup

Place the file in /usr/local/bin

```bash
cd /tmp/
wget https://github.com/charljmert/replace_block/raw/master/replace_block.pl
mv replace_block.pl /usr/local/bin/replace_block
chmod +x /usr/local/bin/replace_block
```

Now just make sure that /usr/local/bin is in your $PATH

```bash
PATH=/usr/local/bin:$PATH
```
