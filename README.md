# ruby-blog

[![CI](https://github.com/konnononko/ruby-blog/actions/workflows/ci.yml/badge.svg)](https://github.com/konnononko/ruby-blog/actions/workflows/ci.yml)

個人開発のブログWebアプリです。Rails 8 + Hotwire でシンプルに作り、必要に応じてドキュメント（`docs/`）に判断を残します。

## 機能（最初のスコープ）
- ユーザー認証
- 記事の投稿
- 記事の表示
- コメントの投稿

## 技術スタック
- Rails 8
- Hotwire
- PostgreSQL
- Kamal（コンテナデプロイ）
- RSpec（最低限のユニットテスト）

## ローカルセットアップ
前提: Ruby / Node.js / PostgreSQL がインストール済み。

```bash
bundle install
```

### 環境変数（.env）
DB認証情報は `.env` で管理します（`.env` はコミットしない）。

必要な値の例:
- `RUBY_BLOG_DATABASE_PASSWORD`

### DB（development / test）
PostgreSQLに接続ユーザー（例: `ruby_blog`）を作成した上で、DBを用意します。

```bash
bundle exec rails db:prepare
RAILS_ENV=test bundle exec rails db:prepare
```

## テスト

```bash
bundle exec rspec
```

## Docker Compose（ローカル検証のみ）

本番デプロイ（Kamal）の代替ではなく、手元で Postgres 付きのコンテナを一度に試すためのものです。

前提: Docker と Docker Compose が使えること。

1. `cp .env.docker.example .env.docker`（Windows PowerShell では `Copy-Item .env.docker.example .env.docker`）
2. `config/master.key` の内容を 1 行そのまま `.env.docker` の `RAILS_MASTER_KEY=` に貼り付ける（コミットしない）
3. `docker compose up --build`
4. ブラウザで http://localhost:3000 を開く（コンテナ内はポート 80、ホストへは 3000 で公開）

DB のユーザー・パスワードは Compose 内で `ruby_blog` / `ruby_blog` に固定している（ローカル検証用）。`.env` で開発しているホストの PostgreSQLとは別ボリュームなので競合しにくい。

トラブル時: ビルドが失敗する場合は `Dockerfile` とログを確認する。画面が表示されない場合は `docker compose logs web` で Rails のログを見る。

## ドキュメント運用
- 開発方針/計画: `docs/dev-planNN.md`
- 作業ログ/備忘録: `docs/dev-logNN.md`
- 重要な設計判断: `docs/adr/`
