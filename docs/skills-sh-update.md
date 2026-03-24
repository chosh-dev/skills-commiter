# skills.sh에 내 skill 업데이트하기

이 문서는 `chosh-dev/skills-commiter` 기준으로 작성되었습니다.

## 어떤 파일을 수정해야 하나

- `skills.sh` 카드/상세에 직접 영향이 큰 파일: `.agents/skills/commiter/SKILL.md`
- 특히 `SKILL.md` frontmatter의 `name`, `description`이 핵심 메타데이터입니다.

예시:

```yaml
---
name: commiter
description: Create precise hunk-level semantic commits ... one pass ...
---
```

## 업데이트 절차

1. `SKILL.md` 수정
2. 커밋

```bash
git add .agents/skills/commiter/SKILL.md
git commit -m "feat: update skill description for skills.sh"
```

3. 원격 반영

```bash
git push origin main
```

4. 인덱싱 재트리거

```bash
npx -y skills add chosh-dev/skills-commiter --skill commiter --yes
```

또는:

```bash
npx -y skills add chosh-dev/skills-commiter@commiter --yes
```

## 반영 확인

```bash
npx -y skills find commiter
```

브라우저 확인:

```text
https://skills.sh/chosh-dev/skills-commiter/commiter
```

## 트러블슈팅

- `find`에 안 뜨고 페이지가 404인 경우:
  - 기다린 뒤 재확인
  - 다른 환경/사용자에서 `skills add`를 한 번 더 실행해 설치 신호 추가
- 저장소가 Private 이면 집계/노출 대상에서 제외될 수 있음
- `SKILL.md` 경로/형식이 깨지면 파싱 실패 가능

