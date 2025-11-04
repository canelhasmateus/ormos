#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///

"""
Test Stability Script
Runs a Gradle task multiple times and reports success/failure statistics
"""

import argparse
import re
import subprocess
import time
from collections import Counter
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict


@dataclass
class RunResult:
    run_number: int
    success: bool
    duration: float
    log_file: Path


class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color


def run_gradle_task(task: str, gradle_args: List[str], log_file: Path) -> tuple[bool, float]:
    """Run a Gradle task and return (success, duration)"""
    cmd = ['./gradlew', task] + gradle_args

    start_time = time.time()

    with open(log_file, 'w') as f:
        result = subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT)

    duration = time.time() - start_time
    success = result.returncode == 0

    return success, duration


def print_header(task: str, gradle_args: List[str], runs: int, warmup: int, results_dir: Path):
    """Print script header"""
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    print(f"{Colors.BLUE}Test Stability Script{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    print(f"Task: {Colors.YELLOW}{task} {' '.join(gradle_args)}{Colors.NC}")
    print(f"Runs: {Colors.YELLOW}{runs}{Colors.NC}")
    print(f"Warmup: {Colors.YELLOW}{warmup}{Colors.NC}")
    print(f"Results dir: {Colors.YELLOW}{results_dir}{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    print()


def run_warmup(task: str, gradle_args: List[str], warmup: int, results_dir: Path):
    """Run warmup iterations"""
    if warmup <= 0:
        return

    print(f"{Colors.YELLOW}Running {warmup} warmup run(s)...{Colors.NC}")

    for i in range(1, warmup + 1):
        log_file = results_dir / f"warmup-{i}.log"
        print(f"Warmup {i}/{warmup}... ", end='', flush=True)

        success, _ = run_gradle_task(task, gradle_args, log_file)

        if success:
            print(f"{Colors.GREEN}✓{Colors.NC}")
        else:
            print(f"{Colors.RED}✗{Colors.NC}")

    print()


def parse_failed_tests(log_file: Path) -> List[str]:
    """Parse Gradle log file and extract failed test names"""
    failed_tests = []

    with open(log_file, 'r') as f:
        content = f.read()

    # Pattern to match failed test methods in Gradle output
    # Matches lines like: "E2EWireOutgoingCreditTest > creates, processes, submits and rejects WIRE outgoing payment() FAILED"
    # The test name can contain spaces, special characters, parentheses, etc.
    pattern = r'^([a-zA-Z0-9_.]+)\s+>\s+(.+?)\s+FAILED$'

    for line in content.split('\n'):
        match = re.match(pattern, line.strip())
        if match:
            class_name = match.group(1)
            test_name = match.group(2).strip()
            full_test_name = f"{class_name}.{test_name}"
            failed_tests.append(full_test_name)

    return failed_tests


def run_tests(task: str, gradle_args: List[str], runs: int, results_dir: Path) -> List[RunResult]:
    """Run test iterations and collect results"""
    print(f"{Colors.YELLOW}Running {runs} test run(s)...{Colors.NC}")

    results = []

    for i in range(1, runs + 1):
        log_file = results_dir / f"run-{i}.log"
        print(f"Run {i}/{runs}... ", end='', flush=True)

        success, duration = run_gradle_task(task, gradle_args, log_file)

        result = RunResult(
            run_number=i,
            success=success,
            duration=duration,
            log_file=log_file
        )
        results.append(result)

        status = f"{Colors.GREEN}✓{Colors.NC}" if success else f"{Colors.RED}✗{Colors.NC}"
        print(f"{status} ({duration:.1f}s)")

    return results


def print_summary(results: List[RunResult]):
    """Print summary statistics"""
    print()
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")
    print(f"{Colors.BLUE}Results{Colors.NC}")
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")

    # Calculate statistics
    total_runs = len(results)
    success_count = sum(1 for r in results if r.success)
    failure_count = total_runs - success_count
    success_rate = (success_count / total_runs) * 100

    durations = [r.duration for r in results]
    avg_time = sum(durations) / len(durations)
    min_time = min(durations)
    max_time = max(durations)

    # Print summary
    print(f"Total runs: {Colors.YELLOW}{total_runs}{Colors.NC}")
    print(f"Successes: {Colors.GREEN}{success_count}{Colors.NC}")
    print(f"Failures: {Colors.RED}{failure_count}{Colors.NC}")
    print(f"Success rate: {Colors.YELLOW}{success_rate:.2f}%{Colors.NC}")
    print()
    print("Timing statistics:")
    print(f"  Average: {Colors.YELLOW}{avg_time:.2f}s{Colors.NC}")
    print(f"  Min: {Colors.YELLOW}{min_time:.2f}s{Colors.NC}")
    print(f"  Max: {Colors.YELLOW}{max_time:.2f}s{Colors.NC}")
    print()

    # Parse and analyze failed tests
    if failure_count > 0:
        print(f"{Colors.BLUE}Analyzing failed tests...{Colors.NC}")
        all_failed_tests = []

        for result in results:
            if not result.success:
                failed_tests = parse_failed_tests(result.log_file)
                all_failed_tests.extend(failed_tests)

        if all_failed_tests:
            # Count occurrences of each failed test
            test_failure_counts = Counter(all_failed_tests)

            print(f"\n{Colors.RED}Flaky Tests (sorted by failure count):{Colors.NC}")
            for test_name, count in test_failure_counts.most_common():
                failure_rate = (count / failure_count) * 100
                print(f"  {Colors.YELLOW}{count:2d}x{Colors.NC} ({failure_rate:5.1f}%) - {test_name}")
        else:
            print(f"{Colors.YELLOW}Could not parse failed test names from logs{Colors.NC}")

        print()

    # Show detailed results
    print(f"{Colors.BLUE}Detailed results:{Colors.NC}")
    for result in results:
        status = f"{Colors.GREEN}✓{Colors.NC}" if result.success else f"{Colors.RED}✗{Colors.NC}"
        log_info = f" - see {result.log_file}" if not result.success else ""
        print(f"  Run {result.run_number}: {status} ({result.duration:.1f}s){log_info}")

    print()
    print(f"{Colors.BLUE}{'=' * 60}{Colors.NC}")

    # Final message
    if failure_count > 0:
        print(f"{Colors.RED}Some test runs failed. Check logs in {results[0].log_file.parent}/{Colors.NC}")
        return False
    else:
        print(f"{Colors.GREEN}All test runs succeeded!{Colors.NC}")
        return True


def main():
    parser = argparse.ArgumentParser(
        description='Run a Gradle task multiple times and report success/failure statistics',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s -t :saturn-cfsb-us:testFunctional -r 20 -- --rerun
  %(prog)s -t :saturn-cfsb-us:testFunctional -r 50 -- --rerun --tests E2EAchOutgoingCreditTest
        """
    )

    parser.add_argument('-t', '--task', required=True,
                        help='Gradle task to run (e.g., :saturn-cfsb-us:testFunctional)')
    parser.add_argument('-r', '--runs', type=int, default=10,
                        help='Number of runs (default: 10)')
    parser.add_argument('-w', '--warmup', type=int, default=0,
                        help='Number of warmup runs (default: 0)')
    parser.add_argument('gradle_args', nargs='*',
                        help='Additional Gradle arguments (e.g., --rerun --tests SomeTest)')

    args = parser.parse_args()

    # Create results directory
    timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
    results_dir = Path(f'test-results-{timestamp}')
    results_dir.mkdir(exist_ok=True)

    # Print header
    print_header(args.task, args.gradle_args, args.runs, args.warmup, results_dir)

    # Run warmup
    run_warmup(args.task, args.gradle_args, args.warmup, results_dir)

    # Run tests
    results = run_tests(args.task, args.gradle_args, args.runs, results_dir)

    # Print summary
    all_passed = print_summary(results)

    # Exit with appropriate code
    exit(0 if all_passed else 1)


if __name__ == '__main__':
    main()