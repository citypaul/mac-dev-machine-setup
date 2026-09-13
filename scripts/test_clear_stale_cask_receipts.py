"""Behaviour tests for scripts/clear-stale-cask-receipts.py.

Run with: python3 -m unittest discover -s scripts -p 'test_*.py'
"""
import importlib.util
import unittest
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "clear_stale_cask_receipts",
    Path(__file__).with_name("clear-stale-cask-receipts.py"),
)
clear_stale = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(clear_stale)


def cask(token, installed="1.0", artifacts=None):
    """A cask as `brew info --cask --json=v2` describes it."""
    if artifacts is None:
        artifacts = [{"app": [f"{token}.app"], "target": f"/Applications/{token}.app"}]
    return {"token": token, "installed": installed, "artifacts": artifacts}


def only_existing(*paths):
    present = set(paths)
    return lambda path: path in present


class StaleCasksTest(unittest.TestCase):
    def test_installed_cask_whose_app_was_deleted_is_stale(self):
        casks = [cask("ghostty"), cask("zed")]

        stale = clear_stale.stale_casks(casks, only_existing("/Applications/zed.app"))

        self.assertEqual(stale, ["ghostty"])

    def test_installed_cask_with_all_its_files_present_is_not_stale(self):
        stale = clear_stale.stale_casks(
            [cask("ghostty")], only_existing("/Applications/ghostty.app")
        )

        self.assertEqual(stale, [])

    def test_cask_brew_has_no_record_of_is_left_for_brew_bundle_to_install(self):
        stale = clear_stale.stale_casks([cask("ghostty", installed=None)], only_existing())

        self.assertEqual(stale, [])

    def test_any_missing_installed_file_makes_the_cask_stale(self):
        artifacts = [
            {"app": ["Foo.app"], "target": "/Applications/Foo.app"},
            {"binary": ["/Applications/Foo.app/Contents/bin/foo"], "target": "/opt/homebrew/bin/foo"},
        ]

        stale = clear_stale.stale_casks(
            [cask("foo", artifacts=artifacts)], only_existing("/Applications/Foo.app")
        )

        self.assertEqual(stale, ["foo"])

    def test_cask_with_no_checkable_install_location_is_never_stale(self):
        artifacts = [
            {"pkg": ["Karabiner-Elements.pkg"]},
            {"uninstall": [{"pkgutil": "org.pqrs.Karabiner-Elements"}]},
        ]

        stale = clear_stale.stale_casks(
            [cask("karabiner-elements", artifacts=artifacts)], only_existing()
        )

        self.assertEqual(stale, [])


if __name__ == "__main__":
    unittest.main()
