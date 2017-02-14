from __future__ import print_function
from __future__ import unicode_literals

import argparse
import os
import sys
import shlex, subprocess
import errno

def makedirs(path):
    """ python implementation of `mkdir -p` """
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise
            
def remove_file(fn):
    try:
        os.unlink(fn)
    except:
        return False
    return True
    
def main():
   # SETTING EXPECTED ARGUMENTS
    parser = argparse.ArgumentParser(add_help=False, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    
    parser.add_argument("-l", "--locale-path",     help="GLibc locale path", required=True)
    parser.add_argument("-c", "--charmap-path",    help="GLibc uncompressed charmap path", required=True)
    parser.add_argument("-g", "--locale-gen",      help="Locale gen file", required=True)
    parser.add_argument("-p", "--prefix",          help="Output prefix", required=True)
    parser.add_argument('--help', action='help', help="Show this help message and exit")

    # GET ARGUMENTS
    args = parser.parse_args()

    locale_path   = args.locale_path
    charmap_path  = args.charmap_path
    locale_gen    = args.locale_gen
    prefix        = args.prefix
    
    full_path     = os.path.join(prefix, 'usr/lib/locale')
    remove_file( os.path.join(full_path, 'locale-archive') )
    with open(locale_gen) as f:
        for line in f.readlines():
            line = line.strip()
            if line:
                if line[0] != '#':
                    tags = line.split(' ')
                    name = tags[0]
                    lang = name.split('.')[0]
                    charmap = tags[1]
                    
                    lang_file = os.path.join(locale_path, lang)
                    charmap_file = os.path.join(charmap_path, charmap)
                    
                    cmd = "localedef -i {0} -c -f {1} --prefix={2} {3}".format(lang_file, charmap_file, prefix, name)
                    output = ""
                    errorcode = 0
                    
                    makedirs(full_path)
                    
                    try:
                        output = subprocess.check_output( shlex.split(cmd) )
                    except subprocess.CalledProcessError as e:
                        output = e.output
                        print(output)
                        errorcode = e.returncode
    
if __name__ == "__main__":
    main()
