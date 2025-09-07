# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pygithub",
#     "requests",
# ]
# ///

import os
import sys
import tempfile
from typing import Tuple, List, Any, Dict
import requests
from pathlib import Path
from github import Github
from github.Repository import Repository
from github.GitRelease import GitRelease

g: Github = Github(os.environ.get("GITHUB_TOKEN"))


def resolve_version(version: str, repo: Repository) -> str:
    if version == "latest":
        release = repo.get_latest_release()
        return release.tag_name
    return version


def download_releases(version: str) -> Tuple[Path, str, str, str]:
    repo: Repository = g.get_repo("cjbind/cjbind")

    tag_name: str = resolve_version(version, repo)

    temp_dir: Path = Path(tempfile.mkdtemp(prefix="cjbind_releases_"))

    release: GitRelease = repo.get_release(tag_name)
    releases: List[GitRelease] = [release]

    for release in releases:
        release_dir: Path = temp_dir / release.tag_name
        release_dir.mkdir(exist_ok=True)

        for asset in release.get_assets():
            asset_path: Path = release_dir / asset.name

            response: requests.Response = requests.get(asset.browser_download_url, stream=True)
            response.raise_for_status()

            with open(asset_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

    print(f"Downloaded releases to: {temp_dir}")
    return [temp_dir, release.tag_name, release.target_commitish, release.name, release.body]


def upload_releases(release_dir: Path, tag_name: str, target_commitish: str, title: str, body: str) -> None:
    gitcode_token: str | None = os.environ.get("GITCODE_TOKEN")

    session: requests.Session = requests.Session()
    session.headers.update(
        {
            "Authorization": f"Bearer {gitcode_token}",
        }
    )

    # https://api.gitcode.com/api/v5/repos/:owner/:repo/releases
    payload: Dict[str, str] = {
        "tag_name": tag_name,
        "name": title,
        "body": body,
        "target_commitish": target_commitish,
    }
    response: requests.Response = session.post(
        "https://api.gitcode.com/api/v5/repos/cjbind/cjbind/releases",
        json=payload,
    )
    response.raise_for_status()
    print(f"Created release at: {response.json()}")

    # https://api.gitcode.com/api/v5/repos/:owner/:repo/releases/:tag/upload_url

    for file in release_dir.glob("**/*"):
        file_name: str = file.name
    
        response = session.post(
            f"https://api.gitcode.com/api/v5/repos/cjbind/cjbind/releases/{tag_name}/upload_url",
            params={
                "file_name": file_name,
            }
        )
        response.raise_for_status()
        
        # {
        #   "url": "string",
        #   "headers": {
        #     "x-obs-meta-project-id": "string",
        #     "x-obs-acl": "string",
        #     "x-obs-callback": "string",
        #     "Content-Type": "string"
        #   }
        # }
        response_data = response.json()
        url = response_data["url"]
        headers = response_data["headers"]
        
        with open(file, "rb") as f:
            response = session.put(url, data=f, headers=headers, timeout=30)
            response.raise_for_status()
            print(f"Uploaded file: {file_name}")



if __name__ == "__main__":
    version: str = sys.argv[1] if len(sys.argv) > 1 else "latest"
    release_dir: Path
    tag_name: str
    target_commitish: str
    title: str
    body: str
    release_dir, tag_name, target_commitish, title, body = download_releases(version)
    
    print(f"Release directory: {release_dir}")
    print(f"Version: {tag_name}")
    print(f"Target commitish: {target_commitish}")
    print(f"Title: {title}")
    print(f"Body: {body}")

    upload_releases(release_dir, tag_name, target_commitish, title, body)