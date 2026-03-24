# skills.sh에 내 skill 새로 등록하기

이 문서는 `chosh-dev/skills-commiter` 기준으로 작성되었습니다.

## 전제 조건

1. GitHub 저장소가 Public 이어야 함
2. 스킬 정의 파일이 저장소에 존재해야 함
3. 스킬 정의 경로 예시: `.agents/skills/commiter/SKILL.md`

## 등록 절차

1. 스킬 메타데이터 확인

```bash
sed -n '1,20p' .agents/skills/commiter/SKILL.md
```

2. 원격에 최신 상태 반영

```bash
git push origin main
```

3. `skills` CLI로 GitHub 소스 설치(인덱싱 트리거)

```bash
npx -y skills add chosh-dev/skills-commiter --skill commiter --yes
```

권장 대체 형식:

```bash
npx -y skills add chosh-dev/skills-commiter@commiter --yes
```

## 등록 확인

1. 검색 확인

```bash
npx -y skills find commiter
npx -y skills find chosh-dev
```

2. 상세 페이지 확인

```text
https://skills.sh/<owner>/<repo>/<skill-name>
예: https://skills.sh/chosh-dev/skills-commiter/commiter
```

## 주의 사항

- `skills.sh`는 수동 업로드 폼이 아니라 `skills add` 설치 텔레메트리 기반 자동 집계입니다.
- 반영에 시간이 걸릴 수 있습니다. (즉시 404가 나올 수 있음)
- 텔레메트리 비활성화(`DISABLE_TELEMETRY=1`) 환경에서는 집계가 누락될 수 있습니다.

