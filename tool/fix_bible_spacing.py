"""
bible.json의 content 필드 띄어쓰기를 맞춥니다.
- 조사(에, 가, 이, 을, 를, …) 앞의 잘못된 공백 제거
- '그종류' → '그 종류' 등 흔한 붙어쓰기 보정
"""
import json
import os
import re

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
BIBLE_PATH = os.path.join(PROJECT_ROOT, "assets", "json", "bible", "bible.json")

# 조사(앞 단어에 붙여 씀). 긴 형태를 먼저 매칭
JOSA = (
    r"에는|에서도|에서는|에게서|한테서|부터는|까지는|까지도|으로는|으로도|"
    r"에서|부터|까지|에게|한테|에는|으로|와는|과는|라고|이라|이며|"
    r"에|가|이|을|를|와|과|로|는|은|도|만|의"
)


def fix_spacing(text: str) -> str:
    # 1) 한글·닫는괄호 뒤 공백 + 조사 → 붙이기 (예: "궁창(穹蒼) 에는" → "궁창(穹蒼)에는")
    text = re.sub(r"([가-힣)\]]) +(" + JOSA + r")\b", r"\1\2", text)
    # 2) "그종류" → "그 종류" (한자 괄호 앞)
    text = re.sub(r"그(종류|땅|지경|사람|일|말씀|이름)\s*(\()", r"그 \1\2", text)
    return text


def main():
    if not os.path.exists(BIBLE_PATH):
        print(f"파일 없음: {BIBLE_PATH}")
        return
    with open(BIBLE_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    changed = 0
    for item in data:
        if "content" not in item:
            continue
        orig = item["content"]
        fixed = fix_spacing(orig)
        if fixed != orig:
            item["content"] = fixed
            changed += 1
    with open(BIBLE_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"완료. {BIBLE_PATH} 저장 (수정된 절: {changed}/{len(data)})")


if __name__ == "__main__":
    main()
