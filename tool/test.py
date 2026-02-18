import json

# 파일 로드
with open('hanja_map.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 데이터 변환
for key, content in data.items():
    all_huns = []
    for char_info in content.get('chars', []):
        hun_list = char_info.get('hun', [])
        if isinstance(hun_list, list):
            all_huns.extend(hun_list)
        elif isinstance(hun_list, str):
            all_huns.append(hun_list)

    # 중복 제거 및 문자열 합치기 (예: "클, 처음")
    content['notes'] = ", ".join(dict.fromkeys(all_huns))

# 파일 저장
with open('hanja_map_updated.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)