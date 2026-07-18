"""
bible.json의 content 필드 띄어쓰기를 맞춥니다.
- 개역개정 흔한 붙여쓰기: '그러나이'→'그러나 이', '내가이'→'내가 이' 등
- ') 에'→')에' 같은 괄호 뒤 조사 병합은 이름 '에서' 등과 충돌해 자동 처리하지 않음
"""
import json
import os
import re

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
BIBLE_PATH = os.path.join(PROJECT_ROOT, "assets", "json", "bible", "bible.json")

# (잘못된 문자열, 올바른 문자열) — 긴 것부터
_PHRASE_FIXES: tuple[tuple[str, str], ...] = (
    ("뿐 아니라이 ", "뿐 아니라 이 "),
    ("하지아니하여이 ", "하지 아니하여 이 "),
    ("청종(聽從)치 아니하여이 ", "청종(聽從)치 아니하여 이 "),
    ("순종(順從)하여이 ", "순종(順從)하여 이 "),
    ("기도(祈禱)하여이 ", "기도(祈禱)하여 이 "),
    ("구(求)하여이 ", "구(求)하여 이 "),
    ("고(告)하여이 ", "고(告)하여 이 "),
    ("위(爲)하여이 ", "위(爲)하여 이 "),
    ("나오게 하여이 ", "나오게 하여 이 "),
    ("어찌하여이 ", "어찌하여 이 "),
    ("그러나이 ", "그러나 이 "),
    ("그러므로이 ", "그러므로 이 "),
    ("하였으므로이 ", "하였으므로 이 "),
    ("이르시되이 ", "이르시되 이 "),
    ("말씀하시되이 ", "말씀하시되 이 "),
    ("가로되이 ", "가로되 이 "),
    ("하였더라이 ", "하였더라 이 "),
    ("아니하며이 ", "아니하매 이 "),
    ("하며이 ", "하매 이 "),
    ("하시매이 ", "하매 이 "),
    ("보소서이 ", "보소서 이 "),
    ("어떠하며이 ", "어떠하매 이 "),
    ("나누이리라이 ", "나누이리라 이 "),
    ("마치시고이 ", "마치시고 이 "),
    ("주시고이 ", "주시고 이 "),
    ("하고이 ", "하고 이 "),
    ("되고이 ", "되고 이 "),
    ("넣고이 ", "넣고 이 "),
    ("가지고이 ", "가지고 이 "),
    ("늙으셨고이 ", "늙으셨고 이 "),
    ("손에서이 ", "손에서 이 "),
    ("이기어이 ", "이기어 이 "),
    ("하시고이 ", "하시고 이 "),
    ("보라이 ", "보라 이 "),
    ("이끌라이 ", "이끌라 이 "),
    ("이르되이 ", "이르되 이 "),
    ("들이라이 ", "들이라 이 "),
    ("너희가이 ", "너희가 이 "),
    ("우리가이 ", "우리가 이 "),
    ("내가이 ", "내가 이 "),
    ("그가이 ", "그가 이 "),
    ("내게이 ", "내게 이 "),
    ("그에게이 ", "그에게 이 "),
    ("에서의이 ", "에서의 이 "),
    ("우리에게이 ", "우리에게 이 "),
    ("에게이 ", "에게 이 "),
    ("께이 ", "께 이 "),
    # '의이'는 '에서의이' 등보다 뒤에 두어야 함
    ("의이 ", "의 이 "),
    ("하여이 ", "하여 이 "),
)


def fix_spacing(text: str) -> str:
    for old, new in _PHRASE_FIXES:
        text = text.replace(old, new)
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
