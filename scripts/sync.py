# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pygithub",
#     "requests",
#     "tqdm>=4.67.1",
# ]
# ///

import os
import sys
import tempfile
from typing import Tuple, List, Dict
import requests
from pathlib import Path
from github import Github, Auth
from github.Repository import Repository
from github.GitRelease import GitRelease
from tqdm import tqdm
from tqdm.utils import CallbackIOWrapper

g: Github = Github(auth=Auth.Token(os.environ.get("GITHUB_TOKEN")))

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

        assets = list(release.get_assets())
        for asset in assets:
            asset_path: Path = release_dir / asset.name

            response: requests.Response = requests.get(
                asset.browser_download_url, stream=True
            )
            if not response.ok:
                print(f"Failed to download file: {asset.name}")
                response.raise_for_status()

            total_size = int(response.headers.get('content-length', 0))
            
            with open(asset_path, "wb") as f:
                with tqdm(total=total_size, unit='B', unit_scale=True, desc=asset.name, leave=True) as pbar:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                        pbar.update(len(chunk))

    print(f"Downloaded releases to: {temp_dir}")
    return [
        temp_dir,
        release.tag_name,
        release.target_commitish,
        release.name,
        release.body,
    ]

def upload_releases(
    release_dir: Path, tag_name: str, target_commitish: str, title: str, body: str
) -> None:
    gitcode_token: str | None = os.environ.get("GITCODE_TOKEN")

    auth_param = {"access_token": gitcode_token}

    session: requests.Session = requests.Session()

    # https://api.gitcode.com/api/v5/repos/:owner/:repo/releases
    payload: Dict[str, str] = {
        "tag_name": tag_name,
        "name": title,
        "body": body,
        "target_commitish": target_commitish,
    }
    response: requests.Response = session.post(
        "https://api.gitcode.com/api/v5/repos/Cangjie-TPC/cjbind/releases",
        json=payload,
        params=auth_param
    )
    if not response.ok:
        print(f"Failed to create release: {response.text}")
        
        error_data = response.json()
        if error_data.get("error_code") == 409:
            print(f"Release already exists: {tag_name}")
        else:
            response.raise_for_status()
    else:
        print(f"Created release at: {response.text}")
    

    # https://api.gitcode.com/api/v5/repos/:owner/:repo/releases/:tag/upload_url

    files = list(release_dir.glob("**/*"))
    files = [f for f in files if f.is_file()]
    
    for file in files:
        file_name: str = file.name

        response = session.get(
            f"https://api.gitcode.com/api/v5/repos/Cangjie-TPC/cjbind/releases/{tag_name}/upload_url",
            params={
                "file_name": file_name,
                "access_token": gitcode_token
            }
        )
        if not response.ok:
            print(f"Failed to get upload url: {response.text}")
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
        print(f"Upload url response data: {response_data}")
        url = response_data["url"]
        headers = response_data["headers"]

        file_size = file.stat().st_size
        with open(file, "rb") as f:
            with tqdm(total=file_size, unit="B", unit_scale=True, unit_divisor=1024, desc=f"Uploading {file_name}", leave=True) as t:
                wrapped_file = CallbackIOWrapper(t.update, f, "read")
                response = session.put(url, data=wrapped_file, headers=headers, timeout=30)
                if not response.ok:
                    print(f"Failed to upload file: {response.text}")
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

    upload_releases(release_dir, tag_name, target_commitish, title, body)
