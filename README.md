# Study Rats — versão online

Frontend estático com Supabase Auth, grupos por código e Realtime. Antes de publicar, substitua `SUPABASE_KEY` em `index.html` pela sua **Publishable key** do Supabase. Nunca coloque uma secret/service_role key no navegador.

1. No SQL Editor do Supabase, rode `online_schema_patch.sql`.
2. No `index.html`, troque `sb_publishable_REPLACE_WITH_YOUR_KEY` pela Publishable key.
3. Suba `index.html` ao GitHub.
4. Publique o repositório no Vercel.
5. No Supabase Auth, configure a URL do site publicada em Redirect URLs se necessário.

O site já implementa cadastro/login, criação de grupo, entrada por código, estudos na nuvem, ranking e Realtime para study_logs/group_members. A Study Room usa Jitsi.
