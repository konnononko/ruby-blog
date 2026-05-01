# ruby-blog

個人開発のブログWebアプリです。Rails 8 + Hotwire でシンプルに作り、必要に応じてドキュメント（`docs/`）に判断を残します。

## 機能（最初のスコープ）
- ユーザー認証
- 記事の投稿
- 読者への記事の公開
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

## ドキュメント運用
- 開発方針/計画: `docs/dev-planNN.md`
- 作業ログ/備忘録: `docs/dev-logNN.md`
- 重要な設計判断: `docs/adr/`
