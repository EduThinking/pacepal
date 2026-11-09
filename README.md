# 페이스팔 (PacePal)

백석대 앞 천호지 코스를 페이스메이커 캐릭터와 함께 달리는 러닝 앱. Supabase(인증·DB·실시간) + Vercel(배포) + GitHub(소스).

## 1. Supabase
1. https://supabase.com → New project (리전 Northeast Asia(Seoul) 권장)
2. SQL Editor → `supabase.sql` 전체 붙여넣고 Run
3. Authentication → Providers → Email → 테스트 중에는 "Confirm email" 끄기 (켜두면 가입 후 메일 인증 필요)
4. Settings → API 에서 `Project URL`, `anon public` key 복사
5. `index.html` 맨 아래 `const CONFIG={url:'...',key:'...'}` 에 입력

## 2. GitHub
새 저장소 만들고 `index.html`, `supabase.sql`, `README.md` 업로드 (웹에서 "Add file → Upload files"로 가능)

## 3. Vercel
https://vercel.com → Add New Project → GitHub 저장소 선택 → Framework: Other → Deploy.
정적 HTML이라 빌드 설정 없이 그대로 배포됩니다. 이후 GitHub에 push할 때마다 자동 재배포.

## 구조
- `index.html` — 앱 전체 (단일 파일)
- `supabase.sql` — 테이블·RLS 정책·실시간 설정
