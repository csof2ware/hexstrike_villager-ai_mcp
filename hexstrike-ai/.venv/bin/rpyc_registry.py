#!/home/leona/projetos/hexstrike-ai/.venv/bin/python
import sys
from rpyc.cli.rpyc_registry import main
if __name__ == '__main__':
    sys.argv[0] = sys.argv[0].removesuffix('.exe')
    sys.exit(main())
