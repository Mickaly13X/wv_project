import os
import argparse
from CoSo.src.parser_custom import Parser


def launch(file):
    
    parser = Parser(file)
    parser.parse()
    count = parser.problem.solve(False)
    print(count)


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', action='store_true')
    parser.add_argument('-f', help='Run solver on file')
    args = parser.parse_args()
    if args.f:
        parser = Parser(args.f)
        parser.parse()
        print(parser.problem)
        print("Running solver...")
        count = parser.problem.solve(log=args.v)
        print(f"Solution: {count}")
    else:
        parser.print_help()
