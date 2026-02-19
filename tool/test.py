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


# 품사만 있는 단어 제외 (뜻풀이로 쓸 수 없음)
POS_ONLY = {"명사", "동사", "형용사", "부사", "대명사", "수사", "조사", "관형사", "감탄사", "접사", "의존명사", "보조동사", "보조형용사", "어미", "품사없음"}


def search_hanja(hanja: str) -> Optional[List[str]]:
    """국립국어원 표준국어대사전 API로 한자 검색 후 뜻풀이만 반환."""
    if not API_KEY or API_KEY == "여기에_인증키_32자리_입력":
        print("설정: KOREA_DICT_API_KEY 환경변수 또는 스크립트 내 API_KEY를 설정하세요.")
        return None
    params = {
        "key": API_KEY,
        "q": hanja,
        "num": 50,
        "advanced": "y",
        "type2": "chinese",
        "req_type": "json",  # JSON 응답 요청
    }
    url = API_URL + "?" + urllib.parse.urlencode(params)
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            body = resp.read().decode("utf-8")
    except Exception as e:
        print(f"  API 오류 ({hanja}): {e}")
        return None

    huns = []
    # 1) JSON: definition 값만 notes 후보로 사용
    body_stripped = body.strip()
    if body_stripped.startswith("{"):
        try:
            data = json.loads(body)
            channel = data.get("channel") or data
            items = channel.get("item", [])
            if items is None:
                items = []
            if isinstance(items, dict):
                items = [items]
            for item in items:
                # origin(한자)에 여러 표기가 들어올 수 있음: "混沌/渾沌" 등
                origin_raw = (item.get("origin") or "").strip()
                origins = [o.strip() for o in origin_raw.split("/") if o.strip()]
                # 검색한 한자(hanja)가 origin 목록에 없으면 스킵
                if hanja not in origins:
                    continue

                # 표준국어대사전 JSON: "sense": { "definition": "전에 없던 것을 처음으로 만듦.", ... }
                val = item.get("sense")
                if isinstance(val, dict):
                    s = val.get("definition")
                    if isinstance(s, str) and s and s not in POS_ONLY and len(s) > 1:
                        huns.append(s.strip())
                elif isinstance(val, list):
                    for v in val:
                        if isinstance(v, dict):
                            s = v.get("definition")
                            if isinstance(s, str) and s and s not in POS_ONLY and len(s) > 1:
                                huns.append(s.strip())
                if huns:
                    break
        except json.JSONDecodeError:
            pass
    # 2) XML: definition 태그 값만 사용
    if not huns:
        try:
            root = ET.fromstring(body)
            for elem in root.iter():
                if "}" in elem.tag:
                    elem.tag = elem.tag.split("}", 1)[1]
            for item in root.findall(".//item"):
                child = item.find("definition")
                if child is not None and child.text and child.text.strip():
                    t = child.text.strip()
                    if t not in POS_ONLY and len(t) > 1:
                        huns.append(t)
                if huns:
                    break
        except ET.ParseError:
            import re
            for m in re.findall(r"<definition[^>]*>([^<]+)</definition>", body):
                t = m.strip()
                if t and t not in POS_ONLY and len(t) > 1:
                    huns.append(t)
    return list(dict.fromkeys(huns)) if huns else None


def main():
    if not os.path.exists(HANJA_MAP_PATH):
        print(f"파일 없음: {HANJA_MAP_PATH}")
        return
    with open(HANJA_MAP_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    total = len(data)
    updated = 0
    # 테스트용: 처음 5개만 확인. 전체 돌릴 때는 TEST_LIMIT를 None으로 바꾸면 됩니다.
    TEST_LIMIT = None
    for idx, (word_key, content) in enumerate(data.items(), 1):
        if TEST_LIMIT is not None and idx > TEST_LIMIT:
            break
        print(f"진행: {idx}/{total}...")
        word = content.get("word", "").strip()
        if not word:
            content["notes"] = ""
            continue
        # 뜻 있으면 notes에 넣고, 없으면 notes는 ""
        result = search_hanja(word)
        if result:
            notes_text = ", ".join(result)
            content["notes"] = notes_text
            # 어떤 단어에 어떤 notes가 들어가는지 확인용 출력
            print(f"[OK] word={word!r} → notes={notes_text!r}")
            updated += 1
        else:
            content["notes"] = ""
        time.sleep(REQUEST_DELAY)

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"완료. {OUTPUT_PATH} 저장 (notes 채운 항목: {updated}/{total})")


if __name__ == "__main__":
    import sys
    # 한 단어만 테스트: python tool/test.py 太初
    if len(sys.argv) > 1:
        test_word = sys.argv[1]
        print(f"검색: {test_word!r}")

        # 디버깅용: 원본 API 응답을 JSON으로 받아 파일로 덤프
        params = {
            "key": API_KEY,
            "q": test_word,
            "num": 50,
            "advanced": "y",
            "type2": "chinese",
            "req_type": "json",
        }
        url = API_URL + "?" + urllib.parse.urlencode(params)
        try:
            with urllib.request.urlopen(url, timeout=10) as resp:
                body = resp.read().decode("utf-8")
        except Exception as e:
            print(f"  API 오류({test_word}): {e}")
            sys.exit(1)

        debug_path = os.path.join(SCRIPT_DIR, "last_api_response.json")
        try:
            parsed = json.loads(body)
            with open(debug_path, "w", encoding="utf-8") as df:
                json.dump(parsed, df, ensure_ascii=False, indent=2)
        except json.JSONDecodeError:
            with open(debug_path, "w", encoding="utf-8") as df:
                df.write(body)
        print(f"  원본 응답(JSON)을 '{debug_path}'에 저장했습니다.")
        print("  (이 파일을 IDE에서 열어 보면 어떤 태그/필드에 뜻풀이가 있는지 확인할 수 있습니다.)")

        # 현재 파서로 추출한 notes도 함께 출력
        result = search_hanja(test_word)
        if result:
            notes = ", ".join(result)
            print(f'  → 추출된 \"notes\": {notes!r}')
        else:
            print('  → 추출된 \"notes\": \"\" (파서가 뜻풀이를 못 찾은 상태)')
    else:
        main()
