"""
국립국어원 표준국어대사전 API를 사용해 hanja_map.json의 한자 훈(뜻)을 조회·보강합니다.
인증키 발급: https://stdict.korean.go.kr/openapi/openApiRegister.do
"""
import json
import os
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from typing import List, Optional

# --------- 설정 ---------
# 환경변수 KOREA_DICT_API_KEY 또는 아래에 직접 입력
API_KEY = os.environ.get("KOREA_DICT_API_KEY", "B88CE2B206BB6E6E48CF5D8457A0C554")
API_URL = "https://stdict.korean.go.kr/api/search.do"
REQUEST_DELAY = 0.5  # API 부담 완화용 초 간격

# 스크립트 기준 경로 (tool/test.py → assets/json/bible/hanja_map.json)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
HANJA_MAP_PATH = os.path.join(PROJECT_ROOT, "assets", "json", "bible", "hanja_map.json")
OUTPUT_PATH = os.path.join(PROJECT_ROOT, "assets", "json", "bible", "hanja_map_updated.json")


def search_hanja(hanja: str) -> Optional[List[str]]:
    """국립국어원 표준국어대사전 API로 한자 검색 후 뜻(훈) 목록 반환. 실패 시 None."""
    if not API_KEY or API_KEY == "여기에_인증키_32자리_입력":
        print("설정: KOREA_DICT_API_KEY 환경변수 또는 스크립트 내 API_KEY를 설정하세요.")
        return None
    params = {
        "key": API_KEY,
        "q": hanja,
        "num": 20,
        "advanced": "y",
        "type2": "chinese",  # 한자어 검색
    }
    url = API_URL + "?" + urllib.parse.urlencode(params)
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            body = resp.read().decode("utf-8")
    except Exception as e:
        print(f"  API 오류 ({hanja}): {e}")
        return None
    # 표준국어대사전은 기본 XML 응답
    huns = []
    try:
        root = ET.fromstring(body)
        # 네임스페이스 제거하여 태그 매칭
        for elem in root.iter():
            if "}" in elem.tag:
                elem.tag = elem.tag.split("}", 1)[1]
        for item in root.findall(".//item"):
            # 뜻풀이: sense, definition 등
            for tag in ("sense", "definition", "dfn", "pos", "definition_info"):
                child = item.find(tag)
                if child is not None and child.text and child.text.strip():
                    huns.append(child.text.strip())
            # sub sense 등
            for sub in item.findall(".//sense") or item.findall(".//definition"):
                if sub.text and sub.text.strip():
                    huns.append(sub.text.strip())
    except ET.ParseError:
        # XML 실패 시 정규식 폴백
        import re
        for pat in (r"<sense[^>]*>([^<]+)</sense>", r"<definition[^>]*>([^<]+)</definition>"):
            huns.extend(re.findall(pat, body))
    if not huns and body.strip().startswith("{"):
        data = json.loads(body)
        items = data.get("channel", {}).get("item", [])
        if isinstance(items, dict):
            items = [items]
        for item in items:
            for key in ("sense", "definition", "dfn"):
                val = item.get(key)
                if isinstance(val, str) and val:
                    huns.append(val.strip())
                elif isinstance(val, list):
                    huns.extend(str(v).strip() for v in val if v)
    return list(dict.fromkeys(huns)) if huns else None


def main():
    if not os.path.exists(HANJA_MAP_PATH):
        print(f"파일 없음: {HANJA_MAP_PATH}")
        return
    with open(HANJA_MAP_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    total = len(data)
    updated = 0
    for idx, (word_key, content) in enumerate(data.items(), 1):
        if idx % 100 == 0:
            print(f"진행: {idx}/{total}...")
        word = content.get("word", "").strip()
        if not word:
            continue
        # word(한자)로 API 조회 후 뜻풀이를 notes에 저장
        result = search_hanja(word)
        if result:
            content["notes"] = ", ".join(result)
            updated += 1
        time.sleep(REQUEST_DELAY)

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"완료. {OUTPUT_PATH} 저장 (notes 채운 항목: {updated}/{total})")


if __name__ == "__main__":
    main()
