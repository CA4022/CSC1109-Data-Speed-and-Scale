from itertools import zip_longest
from pathlib import Path
import tomlkit


class CalVer:
    def __init__(self, v: str):
        self.version_string = v
        self.parsed = [int(i) if i else 0 for i in v.split(".")]

    def __str__(self) -> str:
        return self.version_string

    def __repr__(self) -> str:
        return self.version_string

    def __gt__(self, v: "CalVer") -> bool:
        for i, j in zip_longest(self.parsed, v.parsed, fillvalue=-1):
            if i == j:
                continue
            else:
                return i > j
        return False

    def __ge__(self, v: "CalVer") -> bool:
        for i, j in zip_longest(self.parsed, v.parsed, fillvalue=-1):
            if i == j:
                continue
            else:
                return i > j
        return True

    def __lt__(self, v: "CalVer") -> bool:
        for i, j in zip_longest(self.parsed, v.parsed, fillvalue=-1):
            if i == j:
                continue
            else:
                return i < j
        return False

    def __le__(self, v: "CalVer") -> bool:
        for i, j in zip_longest(self.parsed, v.parsed, fillvalue=-1):
            if i == j:
                continue
            else:
                return i < j
        return True


def get_version(path: Path = Path().cwd()) -> CalVer:
    v = CalVer("0.0.0.0")
    for p in path.iterdir():
        if p.is_dir():
            cur_v = get_version(p)
        elif p.name == "VERSION":
            with p.open("rt") as vfile:
                cur_v = CalVer(vfile.read().strip())
        else:
            continue
        v = v if v > cur_v else cur_v
    return v


def update_pyproject(project_root: Path):
    proj_file = project_root / "pyproject.toml"
    version_file = project_root / "VERSION"
    with proj_file.open("rt") as f:
        t = tomlkit.load(f)
    with version_file.open("rt") as f:
        t["project"]["version"] = f.read().strip()
    with proj_file.open("wt") as f:
        tomlkit.dump(t, f)


def set_project_version(project_root: Path = Path().cwd()):
    highest_version = str(get_version(project_root))
    vfile = project_root / "VERSION"
    vfile.unlink(missing_ok=True)
    with vfile.open("wt+") as v:
        v.write(highest_version)
    update_pyproject(project_root)
    print(f"Project version set to: {highest_version}")


if __name__ == "__main__":
    set_project_version()
