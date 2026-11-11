# Minha Coleção

Coleção de jogos com banco de dados local (SQLite via `sqflite`). No Android/iOS usa o SQLite do aparelho; na web usa o SQLite em WebAssembly com armazenamento no IndexedDB do navegador (`sqflite_common_ffi_web`).

Autor: Gabriel Costa

## Rodar no GitHub Codespaces (sem instalar nada)

1. No repositório: **Code → Codespaces → Create codespace on main**.
2. Aguarde a criação (alguns minutos na primeira vez). A configuração já instala o Flutter e prepara o projeto.
3. No terminal:
   ```bash
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
   ```
4. Quando aparecer o aviso da porta 8080, clique em **Open in Browser**.

## Rodar no computador

```bash
flutter create . --empty --platforms=android,ios,web
flutter pub get
dart run sqflite_common_ffi_web:setup
flutter run
```

## Testes

```bash
flutter test
```

## Teste de persistência

1. Cadastre pelo menos três jogos.
2. Feche o app (ou a aba do navegador).
3. Abra novamente e confirme que os jogos continuam na lista.
