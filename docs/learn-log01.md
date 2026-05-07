# learn-log01

このドキュメントはふりかえりで疑問点や使用技術の理解、解説を記載します。

## 理解・疑問の整理

前提：RubyやRailsの初心者がRailsアプリを個人開発で作成し、開発後に使っている技術の理解を深めようとしています。

- 言語（Ruby）について
    - Rubyの特徴
    - Rubyの得意なこと
    - Rubyで不得意なこと
    - Rubyの基本的な言語機能と文法
    - Rubyに特有の言語機能や文法
- フレームワーク（Rails）について
    - Railsの特徴
    - Railsの得意なこと
    - Railsの不得意なこと
    - Railsの基本的な使いかたや機能
    - Railsに特有な記法（あれば）
    - Railsのアーキテクチャ（MVCなど）
    - Railsのフォルダ構成やファイルの種類、役割、アーキテクチャとの関係
    - Railsでのデータベースの扱い方
- データベース（PostgreSQL）について
    - PostgreSQLの特徴
    - PostgreSQLの得意なこと、不得意なこと
    - PostgreSQLの基本的な機能や使い方、コマンド
- このプロジェクトのコード解説
    - このプロジェクトで作成したコードについて、コードブロックを示しながら、RubyやHTML, CSSのコードを解説
    - アーキテクチャとの関連
    - Rubyの文法的な説明

---

## Rubyについて

### Rubyの特徴

ここでは「Rubyとは何者か」を、後の文法・Rails の話につながるように具体的に整理する。細かい構文はステップ2以降で扱う。

#### インタプリタ型で動的型付け

Ruby のソースは、実行時にインタプリタ（現行の MRI/CRuby では YARV という仮想マシン）が読み取り、逐次実行する。コンパイルしてから配布するスタイル（Go や Rust のバイナリのように）ではない。

変数やメソッドの引数には、あらかじめ「この変数は整数」といった型宣言を書かない。代入やメソッド呼び出しのたびに、オブジェクトが持つクラスに応じた振る舞いが決まる（ダックタイピング：「アヒルのように歩けばアヒル」）。そのため、エディタだけでは拾いにくいミスが実行時まで残りやすい一方、プロトタイプや DSL（ドメイン特化言語）のような柔らかい API を書きやすい。

#### 純粋なオブジェクト指向

Ruby では、数値や `nil` を含め、ほぼすべてがオブジェクトである。`1` もオブジェクトなので `1.odd?` のようにメソッドを呼べる。クラス自体もオブジェクトであり、`Class` のインスタンスとして扱える。メソッド呼び出しが中心で、「データとそれに紐づく操作」がオブジェクトにまとまる設計と相性がよい。

#### ブロック・イテレータ・クロージャ

メソッドに「名前のないコード片（ブロック）」を渡せる。`array.each { |x| ... }` の `{ |x| ... }` が典型で、コレクションの走査だけでなく、ファイルを開いて閉じるまでを `File.open(...) { |f| ... }` のように囲む、といった「前後処理のパターン」に広く使われる。ブロックは外側の変数を捕捉するクロージャにもなる。Rails のルーティングや Active Record のスコープ定義でも、この「ブロックで設定を渡す」スタイルが頻出する。

#### 柔軟な構文と「読みやすさ」を優先した設計

省略可能な括弧、`do`/`end` と `{`/`}` の使い分け、`?`/`!` をメソッド名に付けて述語や危険な操作を区別する慣習など、英語に近い読み味を目指した文法が多い。作成者の松本行弘氏が重んじる「プログラマを楽にする（MINASWAN: Matz is nice and so we are nice）」はコミュニティの空気としても知られ、言語設計のトレードオフでは「一貫性よりも実用と読みやすさ」を選ぶ場面がある、と捉えてよい。

#### メタプログラミングとオープンクラス

実行中にクラスやモジュールにメソッドを追加・再定義できる。`define_method` や `method_missing`、モジュールの `included`/`prepended` フックなどを使うと、繰り返しボイラープレートを減らす API をライブラリ側で生成できる。Rails の `has_many` や `validates` のような宣言的マクロは、この仕組みの上に乗っている。強力な反面、「どこでこのメソッドが定義されたか」が追いにくくなるので、フレームワークに任せる範囲と自前で触る範囲の線引きが重要になる。

#### ガベージコレクション

オブジェクトの寿命はランタイムが推定し、不要になったメモリを回収する。手動 `free` は不要だが、メモリ使用量や一時オブジェクトの大量生成には注意が必要（大規模データ処理では別言語やストリーミング設計と比較検討することがある）。

#### 実装とエコシステム

実務でよく使われるのは MRI（公式の C 実装）。JRuby（JVM 上）、TruffleRuby など別実装もある。ライブラリは RubyGems と `bundler` で依存を宣言し、バージョンを揃える。Rails はその代表例で、「Web アプリ一式」を Gem として引き寄せる世界観になっている。

#### このプロジェクトとの対応関係（先取りの地図）

このリポジトリでは、Ruby は主に次の場所で効いてくる。

- モデル・コントローラ・ヘルパなどの `.rb` ファイルでのロジックと HTTP 応答の組み立て
- ERB テンプレートの `<% %>` / `<%= %>` の中に埋め込まれる Ruby 式
- RSpec の `expect { ... }.to change(...)` のような、ブロックを受け取るマッチャ

「特徴」を押さえたうえで、以下では用途面から見た適性を整理する。そのあと「基本文法」などに進むと、Rails の記法が単なる暗記ではなく、言語の延長として読めるようになる。

### Rubyの得意なこと

「得意」とは、設計思想・エコシステム・慣習が噛み合い、少ない記述で安全に進めやすい領域を指す。万能ではないが、次のような場面で強みが出やすい。

#### リクエスト処理型の Web アプリと Rails

HTTP リクエストを受け、認可・バリデーション・DB 更新・HTML/JSON 応答までを一気通貫で組むスタイルは、Ruby と Rails の主戦場である。ルーティング、ORM、テンプレート、セキュリティ対策のデフォルトが揃っており、個人開発から中規模の業務システムまで、変更を繰り返しながら機能を積み上げやすい。このリポジトリのブログも、その典型例になる。

#### プロトタイプと仕様の早期検証

動的型付けと柔らかいオブジェクトモデルのおかげで、スキーマや API がまだ固まっていない段階でも試行錯誤が速い。後からモデルを分割したり、バリデーションを足したりする道筋も、Rails の規約に沿っていれば迷いにくい。

#### 読みやすさとチーム開発のしやすさ

メソッド名やブロック構文が「文章に近い」形になりやすく、ドメイン語彙をメソッド名に載せた設計（例：`article.editable_by?(user)`）と相性がよい。設定より規約（Convention over Configuration）により、プロジェクト間でフォルダの意味が揃いやすく、オンボーディングコストを下げやすい。

#### 内部ツール・運用スクリプト・タスク自動化

Rake タスクや、短いスクリプトで CSV を読み、API を叩き、メールを送る、といった「バッチ寄りの仕事」も Ruby は得意とされる。ファイルや文字列、時刻の扱いが標準ライブラリと Gem で揃っており、ワンオフでも壊れにくい形に整えやすい。

#### メタプログラミングを活かしたライブラリ・DSL

宣言的な API（Rails の関連定義やバリデーション、ルーティングの `scope` ブロックなど）を、利用者側は短く書ける。フレームワーク作者・Gem 作者にとって表現力が高く、アプリケーション作者にとっては「設定ファイルが Ruby になる」ことで条件分岐や再利用を書ける利点がある。

#### コミュニティと Gem

「やりたいこと」が先にあり、それを Gem で足す文化が根強い。認証（Devise）、テスト（RSpec）、デプロイ補助（このプロジェクトの Kamal など）まで、周辺が揃っていると判断しやすい。

### Rubyで不得意なこと（向きにくい用途）

「不得意」は、言語が最適化してきた軸とズレるとコストが跳ね上がる、という意味で使う。代替や併用技術がある前提で、期待値を合わせておくとよい。

#### ミリ秒単位を争う超低レイテンシ処理

インタプリタの起動・実行モデル、GC の存在により、常時サブミリ秒を切る処理や、カーネルに近いリアルタイム制御の主役には向きにくい。ゲームエンジン、高頻度取引のコア、組み込みファームウェアの第一言語は、通常 C/C++/Rust など別言語になる。

#### CPU をフルに食う数値計算・大規模シミュレーション

素の Ruby は数値ループの最適化が、LLVM ネイティブや SIMD 前提の言語に比べ不利になりやすい。データサイエンスや重い行列演算では、Python から C/Fortran 拡張を呼ぶ構成や、Julia など別言語が主役になることが多い。Ruby 側はオーケストレーションに回す、という住み分けが現実的である。

#### メモリとプロセス数が極端にシビアな環境

長時間稼働するワーカーを大量に立て、1 プロセスあたりの RAM を厳密に抑えなければならない場合、ランタイムとオブジェクトのオーバーヘッドがボトルネックになりうる。対策（チューニング、プロセスモデルの見直し、一部を別言語のマイクロサービスに分離）はあるが、最初から「極小メモリ・極多プロセス」を最優先するなら他言語と比較検討する価値がある。

#### コンパイル時に型を完全に固定したい超大規模モノレポ

動的型付けのままでは、リファクタリング時に実行時まで気づけない不整合が起きうる。Sorbet や RBS による静的型チェック、厳格なレビュー・テストで埋め合わせる道はあるが、「型宣言なしの巨大コードベースを機械的に保証したい」という要件だけを見ると、最初から静的型がデフォルトの言語のほうが負担が小さい場面もある。

#### 単一の小さなネイティブバイナリ配布

依存をすべて静的リンクした 1 ファイルの CLI を配布したい、といった文脈では Go などが選ばれやすい。Ruby もパッケージング手段（Traveling Ruby、mruby、コンテナイメージなど）はあるが、「デフォルトの得意分野」というより運用設計が必要になる。

#### モバイルクライアントの第一言語

iOS/Android の公式スタックは Swift/Kotlin などが中心で、Ruby はサーバーやスクリプト側に置かれることがほとんどである。

---

以上はあくまで適性の整理である。Ruby 3 系の性能改善や JIT の進展により、「向かない」と一刀切りできない領域も増えている。自分のプロジェクトが上の「得意」に近いかどうかを見極め、ボトルネックが「不得意」側に寄ったら別言語・別サービスに切り出す、という設計が現実的である。

### Rubyの基本的な言語機能と文法

ここでは Rails のコードを読むうえで最低限押さえておきたい要素を、短い実行イメージ付きで並べる。細部の例外やエッジケースは公式ドキュメントや書籍で補う想定である。

#### リテラルと真偽・nil

数値は整数と浮動小数の区別がある。`0b` / `0o` / `0x` は二進・八進・十六進。文字列はシングルクォート（展開なし）とダブルクォート（`#{}` で式展開）がある。

```ruby
1 + 2          # => 3
1.5 * 2        # => 3.0
"hello"        # 文字列
'no #{interp}' # そのまま

name = "Ada"
greeting = "Hello, #{name}"  # => "Hello, Ada"

true && false  # => false
nil            # 「値がない」オブジェクト。false ではないが条件では偽として扱われる
```

`if` の条件では、`false` と `nil` だけが偽。`0` や空文字列 `""` は真である（他言語と違うので注意）。

#### シンボル

`:title` のようにコロンで始まる識別子。イミュータブルで、同じ内容なら同一オブジェクトとして扱われやすい。ハッシュのキーや、Rails でメソッド名・カラム名を渡すときに頻出する。

```ruby
:draft == :draft   # => true
{ status: :published }   # キーはシンボル :status（新しいハッシュリテラル記法）
# { :status => :published } のシンタックスシュガー
```

#### 配列とハッシュ

順序付きコレクションとキー・値のマップ。末尾カンマを許すスタイルがよく使われる。

```ruby
titles = ["First", "Second"]
titles << "Third"           # 末尾に追加
titles[0]                   # => "First"

counts = { draft: 1, published: 5 }
counts[:draft]              # => 1
counts.fetch(:missing) { 0 }  # キーがなければブロックの結果（fetch は KeyError を避けたいときに便利）
```

#### 変数の種類（スコープの違い）

ローカル変数は英小文字またはアンダースコア。インスタンス変数は `@title` のようにオブジェクトごとに保持（Active Record の `article.title` の裏で `@attributes` などに繋がるイメージ）。クラス変数は `@@count`（継承で共有される点に注意）。定数は `Article` のように大文字で始まる名前（再代入は警告付きで可能な場合がある）。

```ruby
class Counter
  @@total = 0

  def initialize
    @value = 0
  end

  def bump
    @value += 1
    @@total += 1
  end
end
```

グローバル変数 `$stdout` などは標準ライブラリで見かけるが、アプリケーションコードではほぼ使わない。

#### メソッド定義、引数、戻り値

`def` で定義する。最後に評価された式が戻り値になる（`return` は早期脱出に使う）。引数にはデフォルト値、キーワード引数、可変長引数（`*rest`）を組み合わせられる。

```ruby
def greet(name, punctuation: "!")  # pubctuationはキーワード引数で、デフォルト値が"!"
  "Hello, #{name}#{punctuation}"
end

greet("Bob")                      # => "Hello, Bob!"
greet("Bob", punctuation: "?")    # => "Hello, Bob?"

def line(items)
  items.join(", ")
end

line(["a", "b"])  # => "a, b"
```

メソッド呼び出しの括弧は多くの場面で省略できる。`puts "hi"` と `puts("hi")` は同じ。

```ruby
user.email.upcase  # レシーバ user に対し email を呼び、さらに upcase
```

#### 述語メソッドと危険メソッドの慣習

末尾が `?` のメソッドは真偽を返すことが多い（例：`empty?`）。末尾が `!` のメソッドは「破壊的」に自分自身を変える版であることが多い（例：`sort!`）。Rails では `save` と `save!` のように、失敗時に例外を投げるかどうかの違いに使われる。

```ruby
s = "  hi  "
s.strip   # 新しい文字列 "hi" を返す
s.strip!  # s 自身を変更し、変更がなければ nil
# 定義側で意味に応じて?や!をつける「慣習」になっている。言語側で保障するわけではない。
```

#### 制御構造：if / unless / case

```ruby
if user.nil?    # nil? はBasicObjectに定義されている「自分はnilか」と聞く述語メソッド
  "guest"
elsif user.admin?
  "admin"
else
  "member"
end

# 修飾子形式（1 行に収まるとき）
return if message.nil? || message.empty?

case status
when :draft
  "下書き"
when :published
  "公開"
else
  "不明"
end
```

`unless` は「if not」だが、複雑な条件をねじ込むと読みにくくなるので、シンプルな否定に留めるのが無難である。

#### 繰り返しとイテレータ

インデックスの `for` はほぼ使われず、`each` などのイテレータが標準である。整数には `times` や `upto` がある。範囲オブジェクト `(1..3)` は両端含み、`(1...3)` は終端を含まない。

```ruby
[10, 20, 30].each do |n|    # eachは配列などがもつインスタンスメソッド。Arrayにはeachが定義されいている。内部では要素を順にyieldする実装になっている。|i|はブロックパラメータと呼ばれ、eachが要素を返すたびにその値が入る。
  puts n * 2
end

3.times { |i| puts i }    # Integer#timesはブロックに0,1,2を渡す

(1..3).each { |i| puts i }
```

#### ブロック、`yield`、メソッドオブジェクト（概要）

メソッドの末尾に `do ... end` または `{ ... }` を渡すとブロックになる。定義側は `yield` でブロックを実行する。

```ruby
def with_timing
  t0 = Time.now
  yield
  Time.now - t0
end

with_timing { sleep 0.1 }  # おおよそ 0.1 秒
```

ブロックをオブジェクトとして保持したいときは `lambda` や `proc` を使う（引数の扱いや `return` の挙動が異なる。まずは「ブロックがほとんど」でよい）。

#### クラス、モジュール、`initialize`

`initialize` は `new` から呼ばれるコンストラクタに相当する。`attr_reader` / `attr_writer` / `attr_accessor` でゲッター・セッターを短く定義できる。

```ruby
module Timestamped
  def touch
    @updated_at = Time.now
  end
end
# モジュールはクラスに似ているが、newして使うものではない、継承の親にはしない、代わりにinclude / prepend / extendで機能をミックスインするのに使う。

class Post
  include Timestamped

  attr_accessor :title

  def initialize(title)
    @title = title
    touch
  end
end

p = Post.new("Hello")
p.title # => "Hello"
```

`include` はインスタンスメソッドとしてミックスインする。クラスメソッド側に足すときは `extend` を使う。

#### `self` とクラスメソッド

メソッド定義の文脈によって `self` が指すオブジェクトが変わる。クラス定義の直下で `def self.foo` と書くとクラスメソッドになる。

```ruby
class Article
  def self.from_params(params)
    new(title: params[:title])
  end

  def summary
    "#{self.class.name}: #{@title}"  # インスタンス内では self はこのインスタンス
  end
end
# Article.new.summary のように、インスタンスメソッドはインスタンスに対して呼ぶ Article#summary とドキュメントでは書く
# Article.from_params(params) のように、クラスメソッドはクラスに対して呼ぶ Article.from_params とドキュメントでは書く
```

#### 例外処理

失敗しうる処理を `begin`～`rescue` で囲み、型に応じて分岐する。`ensure` は成功・失敗に関わらず実行される。

```ruby
begin
  File.read("missing.txt")
rescue Errno::ENOENT    # ::は名前空間の区切り
  "(no file)"
end
```

Rails のコントローラやモデルでは、フレームワークが用意したフックや `save!` の例外に任せる場面が多く、あらゆる箇所で `begin`/`rescue` する必要はない。

#### よく見るイディオム

```ruby
# 左側が nil または false なら右側を使う
name = nickname || "anonymous"

# 変数が nil または false のときだけ代入（メモ化の素朴な形）
@cache ||= expensive_computation()

# 安全呼び出し（receiver が nil なら nil を返し、NoMethodError にしない）
user&.profile&.display_name    # userがnilでなければprofileを呼び、nilならprofileを呼ばずに式全体の値はnil

# ハッシュをキーワード引数のように展開（Rails の params 周りで見かける）
opts = { punctuation: "?" }
greet("Bob", **opts)
```

#### このプロジェクトでつながる読み方

- コントローラの `params.require(:article).permit(:title, :body)` は、ハッシュ操作とシンボルキーの典型例である。
- モデルの `validates :title, presence: true` は、クラスマクロにシンボルとオプションハッシュを渡している。
- ビューの `<%= @article.title %>` は、インスタンス変数のゲッター（Active Record が提供）を ERb が出力している。

### Rubyに特有の言語機能や文法

基本文法の外側で、他言語から来ると「Ruby っぽい」と感じる要素をまとめる。Rails はこれらをフレームワーク内部で多用するため、名前だけ知っておくとドキュメントやスタックトレースが読みやすくなる。

#### クラスの再オープン（モンキーパッチ）

同じクラス名の `class` ブロックを後から再度書ける。定義がマージされ、メソッドを追加・上書きできる。ライブラリが「既存クラスに便利メソッドを足す」ときに使われる。強力だが、名前の衝突や挙動変更に注意する。

```ruby
class String
  def shout
    upcase + "!"
  end
end

"hi".shout  # => "HI!"
```

#### メソッド探索と `include` / `prepend` / `extend`

`include M` は通常、インスタンスメソッドとしてミックスインする。`prepend M` は継承チェーンの手前に差し込むため、`super` の向き先が変わり、モジュール側で既存メソッドをラップできる。`extend M` はそのオブジェクト（多くはクラス）の特異クラスにメソッドを足し、クラスメソッドとして使う。

```ruby
module Auditable
  def save(*args, &block)
    puts "saving..."
    super
  end
end

class Article
  prepend Auditable
end
```

Rails の Concern や Active Support の一部は、この仕組みの上に乗っている。

##### 補足

prepend：同じインスタンスメソッドだが、「先に」モジュールを見る
prepend もインスタンスメソッドを足しますが、探索順でモジュールがクラスより前に入ります。

```ruby
module Audit
  def save
    puts "before"
    super   # 次は「本来の C#save」へ
  end
end

class C
  prepend Audit
  def save
    puts "core"
  end
end

C.new.save
# before
# core
```

C にも save があり、Audit にも save があるとき、include だとクラス側が先に勝つことが多い一方、prepend だと モジュールの save が先に呼ばれ、super でクラス本体の save に渡せます。Rails の Concern で「コールバックをラップする」イメージに近いです。

短く言うと、prepend は「インスタンスメソッドを足す」点は include と同じだが、メソッドを探す順番でモジュールをクラスの手前に差すのが違いです。

extend：レシーバ「そのオブジェクト」にだけメソッドを足す
extend M は、渡したオブジェクトの特異クラスにモジュールのインスタンスメソッドを足します。だから：

クラスに対して extend → クラスメソッドになる（self がクラスなので）。
あるインスタンスにだけ extend → そのインスタンスだけがそのメソッドを持つ。

```ruby
module Plugin
  def foo = 42
end

class Foo
  extend Plugin
end

Foo.foo      # => 42（クラスに対して呼ぶ）

obj = "hi"
obj.extend(Plugin)
obj.foo      # => 42（この文字列オブジェクトだけ）

"other".foo  # NoMethodError
```

include が「このクラスの全インスタンスに共通のメソッド」なのに対し、extend は「今指定したオブジェクト（多くはクラス）にだけメソッドを生やす」感じです。

#### splat：`*` と `**`

一つのメソッドに「可変個の位置引数」や「ハッシュ／キーワードをまとめて受け渡し」するときに使う。定義側の `*names` は残りを配列に、`**opts` はキーワード引数をハッシュにまとめる（Ruby 3 系ではキーワードと位置の区別が厳密になっている点に注意）。

```ruby
def combine(first, *rest, **kw)
  [first, rest, kw]
end

combine(1, 2, 3, x: 10)  # => [1, [2, 3], {:x=>10}]
```

#### ブロックを `Proc` として受け取る `&`

メソッドの最後の仮引数が `&block` のとき、渡されたブロックが `Proc` 化される。逆に呼び出しで `&callable` と書くと、`Proc` や `method(:foo)` をブロックとして渡せる。

```ruby
def twice(&block)
  block.call
  block.call
end

twice { puts "hi" }

doubler = proc { |x| x * 2 }    # 組み込みのオブジェクトProcのインスタンスを作成
[1, 2, 3].map(&doubler)  # => [2, 4, 6]    # Procがもつブロック（処理）を渡す
```

#### `define_method` と `class_eval` / `module_eval`

実行時にメソッド名と本体を決められる。DSL や `attr_accessor` のようなマクロの実装の根幹。

```ruby
class Robot
  %i[walk jump].each do |action|    # %iは中身をシンボルにする。[:walk, :jump]と同じ。
    define_method(action) { "#{action}ing" }
  end
end

Robot.new.walk  # => "walking"
```

`class_eval` に文字列を渡す形はメタプログラミングで古くからあるが、セキュリティとデバッグの観点ではブロック形式が推奨されやすい。

#### `method_missing` と `respond_to_missing?`

存在しないメソッドが呼ばれたときにフックできる。Active Record の動的属性（`find_by_email` のような動的スコープ）のような API に使われてきた。現代ではメソッド定義のコストが下がったため、安易に使わず、`respond_to?` と整合させるなら `respond_to_missing?` も実装するのが作法として知られる。

```ruby
class Ghost
  def method_missing(name, *)
    "called #{name}"
  end
end

Ghost.new.foo  # => "called foo"
```

#### 記号付きリテラルとヒアドキュメント

`%w[a b c]` はスペース区切りで文字列配列、`%i[a b c]` はシンボル配列。`%q{}` はシングルクォート相当、`%r{pat}` は正規表現。ヒアドキュメントは複数行文字列。`<<~EOS` は先頭のインデントをそろえて取り除く（チルダ付き）。

```ruby
sql = <<~SQL
  SELECT *
  FROM articles
  WHERE published = TRUE
SQL
```

##### 補足

`<<~`タグ で「ここからヒアドキュメント（複数行の文字列）が始まる」と宣言する。
同じ タグ だけの行で終わりを示す（先頭にスペースを付けないのが基本）。

```ruby
query = <<~HOGEHOGE
  SELECT *
  FROM articles
HOGEHOGE
```

終端の HOGEHOGE は、開始時に書いた名前と完全一致させる必要があります。

`~`（チルダ）の意味: 
`<<~` は終端行に合わせて、各行の先頭の余分なインデントをそろえて削るための書き方です。コードをインデントしながら書いても、文字列としては左端が揃ったきれいな形にできます。

`<<-` や `<<`（チルダなし）だとインデントの扱いが違うので、ドキュメントや Rails でよく見るのは `<<~EOS` や `<<~SQL` のような形です。EOS は "end of string" の略の慣習です。

#### `Struct` と軽いデータ載せ

キーワード引数付き `Struct` で、小さな値オブジェクトや戻り値の束ねを手早く定義できる。Active Record の代替ではないが、スクリプトやテストで見かける。

```ruby
Point = Struct.new(:x, :y, keyword_init: true)    # Point型を定義して返す。クラスを生成するファクトリだと思うと整理しやすい。
Point.new(x: 1, y: 2)
```

#### Refinements（`refine` / `using`）

ファイルやブロック単位でだけ有効なモンキーパッチ。グローバルにクラスを汚染しないが、有効範囲が分かりにくくなることもある。標準ライブラリや一部 Gem で使われる。アプリ本体ではあまり目にしないことが多い。

##### 補足

refine SomeClass do ... end … 「このモジュールの中でだけ、SomeClass にこういうメソッドを足す」と定義する。
using ThatModule … 「このレキシカルスコープ（ファイルやブロックの範囲）では、その refine を有効にする」。

```ruby
module Shout
  refine String do
    def shout
      upcase + "!"
    end
  end
end

using Shout

puts "hello".shout   # => HELLO!
```

同じファイルの using Shout より下では "hello".shout が使えます。

#### 特異メソッドと `class << self`

特定の一つのオブジェクトだけに付けるメソッドを特異メソッド（シングルトンメソッド）という。`class << obj` はそのオブジェクトの特異クラスを開く構文。クラスメソッドをまとめて書くときに `class << self` が使われる。

```ruby
obj = "hello"
def obj.shout
  upcase + "!"
end

class Foo
  class << self
    def bar
      1
    end
  end
end
```

#### `||` と `or` の優先順位の落とし穴

`||` のほうが結合が強い。`or` は優先順位が低く、制御フローの「左が真なら右を評価しない」用途で使われることもあるが、代入と組み合わせると直感と違う解釈になることがある。迷ったら `||` と括弧で書くほうが安全なことが多い。

```ruby
# 意図：name がなければ代入
# name = nil or "guest"  # これは (name = nil) or "guest" になりやすい（意図と違う）
name = nil || "guest"    # => "guest"
```

#### まとめ：Rails との関係

- ルーティング、コールバック、`validates` などは「クラス定義時にブロックとシンボルを渡し、内部で `define_method` やフックでつなぐ」パターンが多い。
- `params` の展開、スコープの `-> { where(...) }`、RSpec の `expect { }.to change` は、ブロックと `&`、lambda の文化に乗っている。
- 再オープンと Active Support の `String` / `Hash` 拡張は、プロジェクトで `blank?` などが「標準のように」見える理由のひとつである。

ここまでで Ruby の輪郭は揃う。以下では同じドキュメント内で Rails にフォーカスを移す。

## Railsについて

### Railsの特徴

Rails は Ruby 上に構築されたフルスタックの Web アプリケーションフレームワークである。HTTP からデータベース、HTML 応答、バックグラウンドジョブやメールまで、Web サービスに必要な要素をひとつの規約の下にまとめる設計が特徴になる。

#### 設定より規約（Convention over Configuration）

ファイル名・クラス名・テーブル名・URL の形など、繰り返し決まることをフレームワーク側が仮定し、設定ファイルを薄く保つ。迷いどころが減り、新規参加者も「だいたいここに書く」で済みやすい。一方、規約から外れた構成には追加の設定や説明コストがかかる。

#### MVC とリクエストの流れ

ブラウザからのリクエストはルーティングでコントローラのアクションに割り当てられ、モデル（ドメインと永続化）とビュー（テンプレート）を組み合わせて応答を組み立てる。責務の分離が学習の入口にもなり、拡張時も変更箇所を探しやすい。

#### Active Record とデータベース

リレーショナル DB をオブジェクトとして扱う ORM レイヤが標準で統合されている。マイグレーションでスキーマをバージョン管理し、モデルにバリデーションや関連（`has_many` など）を宣言するスタイルが主流である。このリポジトリでも PostgreSQL と組み合わせて使っている。

#### ルーティング・コントローラ・ビュー・ヘルパ

URL とコードの対応、Strong Parameters、フィルタ（`before_action` など）、ERB やパーシャル、フラッシュ・セッションまわりが一体として提供される。HTML フォームとコントローラのつなぎ方もパターン化されている。

#### デフォルトの安全対策の方向性

クロスサイトリクエストフォージェリ（CSRF）トークン、コンテンツセキュリティやエスケープの考え方など、Web 特有のリスクに対して「最初からそう動く」前提が多い（すべてを保証するわけではなく、アプリ固有の検証は別途必要）。

#### Hotwire（Turbo / Stimulus）とモダンな UI

近年の Rails は、フル SPA を前提にせず、サーバー主導の HTML を保ちつつ部分的な更新や軽い JavaScript を足す Hotwire 系が推奨される流れにある。このプロジェクトの技術スタック（Rails 8 + Hotwire）もその延長線上にある。

#### ジェネレータとタスク

`rails generate` でモデル・コントローラ・マイグレーションの雛形を生成したり、`rails db:migrate` や `bin/dev` など開発・運用用のコマンドが揃う。個人開発からチーム開発まで、作業の型を共有しやすい。

#### Ruby と Gem との一体性

Rails 自体が巨大な Gem であり、認証・テスト・デプロイなどは別 Gem で足す文化と相性がよい。言語レベルの柔らかさ（ブロック、メタプログラミング）をフレームワークが内部で活用しているため、表向きは宣言的な DSL に見えることが多い。

#### まとめ

Rails は「Web アプリ一式を、決まった型で素早く安全に進める」ためのフレームワークである。用途面の適性は次の見出しで整理する。

##### 補足

ルーティング（Routing）:
「この URL（と HTTP メソッド）を、どのコントローラのどのアクションに渡すか」を決めるルールのこと。config/routes.rb に書くことが多いです。例: GET /articles → ArticlesController#index。

コントローラ（Controller）:
リクエストを受け取り、モデルやビューを使って処理を組み立てるクラス。認可・パラメータの扱い・リダイレクトやステータスコードの決定など、HTTP の入口に近い役割です。ArticlesController のような名前で、index / show / create などのメソッドが「アクション」になります。

Strong Parameters（ストロングパラメータ）:
クライアントから送られた params のうち、どのキーをモデルに渡してよいかをホワイトリストで許可する仕組み。params.require(:article).permit(:title, :body) のように書き、意図しない属性の一括代入（Mass Assignment）を防ぎます。

パーシャル（Partial）:
ビューの部品テンプレート。_form.html.erb のようにファイル名が _ で始まり、render "form" などで他のテンプレートに埋め込みます。同じフォームや一覧行を繰り返し使うときに使います。

フラッシュ（Flash）:
次の 1 リクエストだけ表示したい短いメッセージ用の仕組み。redirect_to ..., notice: "保存しました" の notice や alert が典型で、レイアウトで flash を読んで表示します。リダイレクト後に一度だけユーザーに伝えたい内容向けです。

セッション（Session）:
サーバー側（や暗号化クッキー）に保持するユーザーごとの小さな状態。ログイン状態やカートの中身など、複数リクエストにまたがって覚えておきたい情報を置きます。フラッシュより長く持つ用途向けです（実装は設定によります）。

CSRF（Cross-Site Request Forgery）:
別サイト上の罠ページなどから、ログイン済みユーザーに意図しないリクエストを送らせる攻撃の総称。Rails はフォームに CSRF トークンを付け、正規ページ経由の POST かどうかを検証するデフォルトの仕組みがあります（protect_from_forgery など）。

### Railsの得意なこと

「得意」とは、規約・部品・コミュニティ知識が揃い、少ない決断でプロダクトに近い成果が出やすい領域を指す。

#### サーバー中心の Web アプリと CRUD 中心の業務

画面遷移、フォーム、認可、DB の読み書き、一覧・詳細・編集といった王道の形に強い。このリポジトリのブログのように、HTML を返すアプリを短時間で形にしやすい。

#### プロトタイプから中規模サービスまでの立ち上げ

ジェネレータとマイグレーションでスキーマと画面のたたき台が早い。仕様が変わっても、MVC の分割と Active Record のまわりで修正箇所を追いやすい。

#### 規約によるチームの同期

フォルダとファイルの意味がプロジェクト間で似通うため、参加直後から「どこを読めばよいか」が推測しやすい。レビューや引き継ぎのコストを下げやすい。

#### リレーショナル DB と一体の設計

トランザクション、関連、バリデーション、スコープをモデルに寄せるスタイルが確立している。PostgreSQL のような RDBMS と組み合わせた業務アプリと相性がよい。

#### Hotwire による「薄いフロント」

フル SPA を組まずに、サーバーが HTML を組み立て、必要なところだけ Turbo や Stimulus で補う構成に向く。JavaScript のビルド地獄を小さく保ちやすい。

#### Gem とドキュメント文化

認証、管理画面、テスト、デプロイなど、よくある要件は Gem と記事で手がかりが取りやすい。困ったときの検索ヒット率が高いほうに属する。

### Railsの不得意なこと（向きにくい用途）

「不得意」は、フレームワークの前提とズレると戦い続けることになる、という意味で使う。代替アーキテクチャや別レイヤの併用が現実的になる場面がある。

#### クライアント主導の巨大 SPA だけを載せる場合

画面の状態とルーティングのほとんどをブラウザ側フレームワークに置き、サーバーは JSON API に限定するなら、Rails の HTML 中心の強みを活かしにくい。API モードや別バックエンドの選択肢と比較される。

#### 規約と真逆のディレクトリやデータモデル

既存の命名や URL 規則をすべて捨てたい、といった要件では設定と説明コストが膨らむ。フレームワークと折り合いを付けられないなら別の土台も検討対象になる。

#### 超低レイテンシや組み込みの主役

言語ランタイムとフレームワークの重なりはある。ミリ秒単位を争う基盤やファームウェアの第一選択には向きにくい（Ruby 自体の不得意分野と重なる）。

#### 「Rails だけ」で無限スケールを期待する場合

アクセスが増えるとキャッシュ、ジョブキュー、読み取り専用レプリカ、サービス分割など、アプリケーション設計とインフラの追加が必要になる。Rails は出発点として強いが、規模の先は別の工夫が要る。

#### モバイルアプリの本体

iOS/Android の UI とロジックの主役は各プラットフォームのスタックに置かれることが多く、Rails はバックエンドや管理画面として横に置かれることがほとんどである。

---

以上は適性の整理である。不得意な軸に近づいたら、Rails をやめるのではなく API 化・マイクロサービス化・バッチ分離などで住み分ける選択も多い。

### Railsの基本的な使い方や機能

日常開発で繰り返し触れる単位を、リクエストの流れに沿って並べる。細部はバージョンやプロジェクト設定で差があるため、公式ガイドと自分の `config` をあわせて読むとよい。

#### 開発の起動とコマンド

プロジェクトルートで依存を `bundle install` したうえで、`bin/dev` や `bin/rails server` でアプリを起動する構成が一般的である。Rails 本体やタスクは `bin/rails`（旧 `rails`）経由で呼ぶ。`bin/rails console`（`c`）で対話的にモデルを試せる。ルート一覧は `bin/rails routes`、DB マイグレーションは `bin/rails db:migrate`、ロールバックは `db:rollback` など。

```bash
# Gemfile の依存をインストール（初回や Gem 変更後）
bundle install

# 開発用にサーバ（とフロントのウォッチャ等）をまとめて起動する例（プロジェクトにより bin/dev の中身は異なる）
bin/dev

# Puma のみ起動したい場合の例
bin/rails server
# 別名: bin/rails s

# 対話シェル。モデルや DB をその場で試せる
bin/rails console
bin/rails c

# ルートとコントローラアクションの対応表を表示
bin/rails routes

# 未適用のマイグレーションを DB に反映
bin/rails db:migrate

# 直前のマイグレーションを 1 段戻す（STEP=2 などで複数段も可）
bin/rails db:rollback
```

#### ルーティング（`config/routes.rb`）

URL とコントローラアクションの対応を宣言する。`resources :articles` のように書くと、REST 風の `index` / `show` / `new` / `create` / `edit` / `update` / `destroy` がまとめて定義される。`only` / `except` で削ったり、`member` / `collection` で追加のパスを足したりする。

```ruby
# config/routes.rb のイメージ（このリポジトリに近い形）
Rails.application.routes.draw do
  # Devise がログイン・登録用のルートを一括で定義する
  devise_for :users

  # GET / → PagesController#home
  root "pages#home"

  # articles の REST 7 アクション + ネストした comments（create / destroy のみ）
  # 例: POST /articles/:article_id/comments → CommentsController#create
  resources :articles do
    resources :comments, only: %i[create destroy]
  end
end
```

#### コントローラ（`app/controllers`）

リクエストごとにインスタンスが作られ、アクション（メソッド）が呼ばれる。`before_action` で共通処理（認証・認可・共通のセットアップ）を挟める。`params` はリクエストパラメータのラッパで、Strong Parameters で許可した属性だけをモデルに渡す。`render` でテンプレートやステータスを選び、`redirect_to` で別 URL へ送る。

```ruby
# コントローラのイメージ（説明用。実ファイルとは行数・名前が完全一致しない場合がある）
class ArticlesController < ApplicationController
  # ログイン必須。index / show だけ例外
  before_action :authenticate_user!, except: %i[index show]    # 補足：シンボルリテラル :authenticate_user! + キーワード引数 except: ...
  # 複数アクションで @article をセット
  before_action :set_article, only: %i[show edit update destroy]

  def show
    # インスタンス変数はビュー（show.html.erb）から参照される
    @article = Article.find(params[:id])
  end

  def create
    # Strong Parameters で許可したキーだけ渡す（Mass Assignment 対策）
    @article = current_user.articles.build(article_params)
    if @article.save
      redirect_to @article, notice: "保存しました"
    else
      # 422 Unprocessable Entity でフォーム再表示（バリデーションエラー表示用）
      render :new, status: :unprocessable_entity
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body)
  end
end
```

#### モデルと Active Record（`app/models`）

DB のテーブルと対応するクラスがモデルになることが多い。`rails generate model` とマイグレーションでカラムを定義し、`validates` でバリデーション、`has_many` / `belongs_to` などで関連を宣言する。`User.find(1)`、`Article.where(...)`、`article.save` のような API で CRUD に近い操作をまとめる。

```ruby
# app/models/article.rb に近いイメージ
class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy # 記事削除時にコメントも削除

  validates :title, :body, presence: true
end

# bin/rails console 内での操作例
# article = Article.find(1)           # 主キー検索（なければ RecordNotFound）
# Article.where(user_id: 1).to_a      # 条件に合うレコードの配列
# article.update(title: "新タイトル")  # 成功すれば true、バリデーション失敗なら false
```

##### 補足

Active Record はふたつの意味で使われますが、Rails の文脈ではだいたい後者を指します。

1. デザインパターンの名前（Martin Fowler）:
「データベースの 1 行 ↔ アプリケーション内の 1 オブジェクト」と対応させ、そのオブジェクトにデータの読み書きやビジネスルールを載せる考え方を Active Record パターンと呼びます。

2. Rails に組み込まれている ORM（よく言う「Active Record」）:
Rails では ApplicationRecord を継承したモデルクラス（例: class Article < ApplicationRecord）がこのパターンを実装した ORM（Object-Relational Mapping）レイヤです。

ざっくり役割は次のとおりです。

テーブルの行を Ruby のオブジェクトとして扱う（Article.find(1)、article.save など）。
カラムをアトリビュートとして読み書きする（article.title）。
関連（has_many / belongs_to など）でテーブル間のつながりを表す。
バリデーション（validates）や スコープ（scope / where チェーン）をモデルに書ける。
マイグレーションと組み合わせてスキーマを管理する。
つまり、「SQL を直接たくさん書かずに、Ruby のクラスとメソッドで DB を操作するための中心部品」だと捉えるとよいです。Rails の「M」の主役はこの Active Record モデルです。

#### ビューとヘルパ（`app/views`）

ERB（`.html.erb`）に HTML と `<%= %>` で式を埋め込む。`app/views/layouts/application.html.erb` が共通枠。`_foo.html.erb` をパーシャルとして `render` する。`link_to`、`form_with`、`button_to` などはヘルパで、適切な URL やメソッド属性を生成する。

```erb
<%# この行は出力しない（ERB のコメント） %>

<%# エラーがあるときだけ一覧表示 %>
<% if article.errors.any? %>
  <ul>
    <% article.errors.full_messages.each do |message| %>
      <li><%= message %></li><%# <%= はエスケープ付きで出力 %>
    <% end %>
  </ul>
<% end %>

<%# model: に渡すと URL・HTTP メソッド（POST/PATCH 等）を推測してフォームを生成 %>
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>
  <%= form.submit %>
<% end %>

<%# 別テンプレートからパーシャル _form.html.erb を差し込む例 %>
<%# <%= render "form", article: @article %> %>
```

#### アセットとフロントまわり

スタイルシートや JavaScript は `app/assets` や `app/javascript` に置き、パイプラインや importmap などプロジェクトの設定に従って配信される。このリポジトリでは Hotwire（Turbo・Stimulus）を使う前提で初期化されていることが多い。

```ruby
# app/views/layouts/application.html.erb に近い記述のイメージ（実ファイルのタグ名は環境で異なる場合がある）
<%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
<%= javascript_importmap_tags %>
# ...
<%= yield %>  <%# 各アクションのテンプレートがここに埋まる %>
```

#### 設定と環境（`config`）

`database.yml` で DB 接続、`routes.rb` でルート、`environments/development.rb` などで環境別の挙動（ログレベル、キャッシュ、ホスト許可など）を切り替える。秘密情報は.credentials や環境変数に寄せる。

```yaml
# config/database.yml のイメージ（development のみ抜粋）
development:
  adapter: postgresql
  encoding: unicode
  database: myapp_development
  # 接続先ホスト・ユーザーは環境変数や別ファイルに分けることも多い
  # host: localhost
  # username: ...
  # password: ...
```

#### メール・ジョブ・タスク（概要）

`Action Mailer` でメール送信クラスを定義し、コントローラやジョブから呼ぶ。重い処理は `Active Job` とバックエンド（Redis など）に任せる構成にできる。Rake タスクは `lib/tasks` に `.rake` で定義し、`bin/rails task_name` で実行する。

```ruby
# app/mailers/application_mailer.rb を継承したメイラーのイメージ
class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: "Welcome")
  end
end

# コントローラ等から: UserMailer.welcome(user).deliver_later

# app/jobs/application_job.rb を継承したジョブのイメージ
class HeavyJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    # 時間のかかる処理（メール送信・外部 API など）
    record = Article.find(record_id)
    # ...
  end
end

# lib/tasks/blog.rake のイメージ
namespace :blog do
  desc "One-line description for bin/rails -T"
  task refresh_counts: :environment do
    # :environment で Rails アプリをロードしてから実行
    puts Article.count
  end
end
# 実行例: bin/rails blog:refresh_counts
```

#### テスト（このプロジェクトでは RSpec）

`rails generate` に相当する Spec や、`spec/requests` で HTTP まで含めた検証を書く。フレームワークのデフォルトは Minitest だが、本リポジトリは AGENTS に従い RSpec を使う。

```ruby
# spec/requests/articles_spec.rb に近いイメージ
require "rails_helper"

RSpec.describe "Articles", type: :request do
  it "lists articles" do
    # GET リクエストをシミュレート
    get articles_path
    # レスポンスの HTTP ステータスを検証
    expect(response).to have_http_status(:success)
  end
end
```

#### 1 リクエストの流れ（おさらい）

ルーティングでアクションが決まる → コントローラが `params` とモデルを扱う → ビューが HTML を組み立てる（またはリダイレクト）→ レスポンスが返る。この線に沿ってファイルを開くと、迷子になりにくい。

```
1. GET /articles/5 → routes.rb が ArticlesController#show に割り当て
2. ArticlesController#show が params[:id] で Article を取得し @article をセット
3. render が省略されていれば既定で app/views/articles/show.html.erb を表示
4. レイアウト application.html.erb の <%= yield %> にテンプレート本体が差し込まれる
（redirect_to の場合は 3 がスキップされ、別 URL へのレスポンスになる）
```

### Railsに特有な記法

Ruby の文法に加え、Rails が DSL（ドメイン特化したメソッドの並び）として用意している記法が多い。ここでは頻出のものを「見た目」と「役割」で整理する（すべてが Rails 独占というより「Rails でよく見る」ものが中心）。

#### ルーティング DSL（`routes.rb`）

`draw` のブロックの中だけが特別なミニ言語のように読める。`resources`、`namespace`、`scope`、`member` / `collection` などが宣言的に HTTP とコントローラを結ぶ。

```ruby
# REST の 7 アクションをまとめて定義
resources :articles

# URL プレフィックスとモジュールをまとめる例（管理画面など）
namespace :admin do
  resources :posts
end

# 追加アクションをネストしたパスに付ける例
resources :articles do
  member do
    get :publish   # GET /articles/:id/publish
  end
end
```

#### コントローラのフィルタとオプション

`before_action`、`around_action`、`after_action` にメソッド名をシンボルで渡し、`only` / `except` でアクションを限定する書き方が定番である。

```ruby
before_action :authenticate_user!, except: %i[index show]
before_action :set_article, only: %i[show edit update destroy]
```

#### Active Record の宣言マクロ

モデルクラス直下で関連・バリデーション・スコープなどを宣言する。実行時にメソッドやコールバックが組み立てられる。

```ruby
belongs_to :user
has_many :comments, dependent: :destroy
validates :title, presence: true

# よく使うクエリに名前を付ける例
scope :published, -> { where(published: true) }
```

#### Strong Parameters のイディオム

`require` でルートキーを固定し、`permit` で許可リストを渡す三連が Rails の定番形である。

```ruby
params.require(:article).permit(:title, :body)
```

#### パスヘルパと URL ヘルパ

ルーティングから `_path`（相対パス文字列）と `_url`（スキーム・ホスト込み）が生成される。`articles_path`、`article_path(@article)` のようにモデルや id を渡せる。

```erb
<%= link_to "一覧", articles_path %>
<%= link_to @article.title, article_path(@article) %>
```

#### ビューとレイアウトのコンポジション

`render` の省略形、`content_for` と `yield :sidebar` のような名前付きプレースホルダ、`<%= yield %>` でレイアウトに本文を差し込むのが Rails 流の分割である。

```erb
<% content_for :title, "ページタイトル" %>
<%# レイアウト側では yield :title など %>
```

#### マイグレーション DSL

`change` メソッドの中で `create_table`、`add_reference`、`t.string` などを並べ、スキーマを Ruby でバージョン管理する。

```ruby
create_table :articles do |t|    # 補足：メソッド呼び出し（マイグレーション DSLの一部） + シンボルリテラル + ブロック
  t.string :title, null: false    # 補足：tオブジェクトのメソッド呼び出し + シンボル + キーワード引数
  t.text :body
  t.references :user, null: false, foreign_key: true
  t.timestamps
end
```

#### Concern（`app/models/concerns` / `app/controllers/concerns`）

共通処理をモジュールに切り出し、`include` と `ClassMethods` ブロックなどでモデルやコントローラに混ぜるパターンが公式に推奨されている（ファイル配置も規約化されている）。

#### Active Support 由来の拡張メソッド

`1.day.ago`、`presence`、`blank?`、`try` など、Ruby 標準にはないメソッドがモデル・文字列・時刻などに生える。Rails のコードやビューで頻出するが、素の Ruby だけでは存在しないこともある。

#### Gem と initializer

`Gemfile` で依存を宣言し、`config/initializers/*.rb` で起動時に設定を注入する。フレームワークというよりエコシステムだが、Rails プロジェクトではこの組み合わせが「よくある記法」として繰り返し現れる。

---

Ruby のメタプログラミングの上にこれらの DSL が載っているため、「メソッドのように見えるキーワード」が増える。迷ったら公式ガイドの該当章と、そのメソッドの API ドキュメントを参照するとよい。

### Railsのアーキテクチャ

Rails は単一の巨大クラスではなく、HTTP の入口からテンプレートと DB までを役割ごとに分割し、規約でファイル配置と名前を対応させる。ここでは全体の骨格だけを押さえる。

#### MVC と責務

- Model（`app/models`）… ドメインルール、バリデーション、永続化（Active Record）。DB との境界がここに集まる。
- View（`app/views`）… HTML（や JSON）の組み立て。プレゼンテーションに近い変更はビューやヘルパへ。
- Controller（`app/controllers`）… リクエスト単位のオーケストレーション。認可・パラメータ整形・どのテンプレートを返すかの決定。

「Fat Model / Skinny Controller」を目指すといった格言は、ビジネスルールをモデル側に寄せ、コントローラは薄く保つという整理である（絶対ではないが読み手への指針になりやすい）。

#### リクエストからレスポンスまでの流れ

おおよそ次の順で処理が流れる。

1. Rack 互換のサーバが HTTP を受け取る。
2. ミドルウェアスタック（ログ、セッション、CSRF など）がリクエストを通過させる。
3. ルータがパスとメソッドからコントローラアクションを決める。
4. コントローラがモデルを読み書きし、`render` または `redirect_to` で応答を決める。
5. ビューが組み立てられ、レイアウトで包まれてレスポンスボディになる。

エラー時や API では JSON のみ返す、といった分岐もコントローラとビュー（または `jbuilder` 等）の組み合わせで行う。

#### 規約とディレクトリ

クラス名・ファイル名・テーブル名・URL が対応する前提で、`app/` 以下が機能別に割れる。`config/routes.rb` が URL 空間の設計図、`db/schema.rb`（または構造ダンプ）が現在のスキーマの写しになる。迷ったときは「どの層の責務か」を先に決めると置き場所が決まりやすい。

#### データ層とマイグレーション

スキーマの変更はマイグレーションでバージョン管理し、実行結果がモデル（Active Record）の前提となる。関連（`has_many` など）はオブジェクトグラフとしての読み書きを単純化するが、複雑なクエリはスコープや SQL に逃がす判断もある。

#### 横断的関心事

認証（このプロジェクトでは Devise）、権限チェック、`before_action`、Concern による共有ロジックなど、複数コントローラやモデルにまたがる処理をどこに置くかが設計の論点になる。

#### フロントエンドの位置づけ

デフォルトではサーバーが HTML を組み立て、CSS・JavaScript はアセット機構や importmap 経由でブラウザへ渡す。Hotwire（Turbo / Stimulus）は、その HTML 中心の延長で部分的な更新や軽い振る舞いを足すためのレイヤとして置かれることが多い。

#### 周辺サブシステム

メール（Action Mailer）、非同期処理（Active Job）、定期・ワンショットのバッチ（Rake）、これらは MVC の外側だが、ユースケースに応じてコントローラやモデルから呼び出される。

#### このリポジトリでの対応関係（先取りの地図）

記事・コメント・ユーザー認証がモデルとコントローラに分かれ、ビューは ERB とパーシャル、スタイルは `application.css`、テストは RSpec のリクエストスペックで HTTP を検証する、という線で読める。詳細は後続の「フォルダ構成」「このプロジェクトのコード解説」でファイル単位に落とすとよい。

### Railsのフォルダ構成・ファイルの種類と役割（アーキテクチャとの関係）

Rails はルート直下を用途ごとに分割し、`app/` がアプリケーション本体、`config/` が振る舞いの設定、`db/` が永続化の履歴、という住み分けになる。ここでは代表的なディレクトリと、アーキテクチャ上のどの層に効くかを対応させて読む。

#### ルート直下に並ぶ主なディレクトリ

- `app/` … HTTP に応答する本体（コントローラ・モデル・ビューなど）。
- `config/` … ルート、DB、環境別設定、初期化子、デプロイ（Kamal など）の宣言。
- `db/` … マイグレーション、`schema.rb`（または `structure.sql`）、シードスクリプト。
- `lib/` … アプリ固有のライブラリやタスク。自動読み込みの設定はプロジェクトによる。
- `public/` … 静的ファイル。Rails が処理しないパスでそのまま配信されるもの。
- `storage/` … Active Storage を使う場合のアップロード置き場など。
- `tmp/` … キャッシュ、ソケット、ログの退避など一時ファイル。
- `log/` … 環境別ログ。
- `vendor/` … サードパーティ資産を置くことがある（頻度は低下気味）。
- `bin/` … `rails`、`setup`、`dev` など実行可能ラッパ。
- `spec/`（本プロジェクト）または `test/` … 自動テスト。AGENTS では RSpec を使用する。

アーキテクチャの話でいう「リクエスト処理の中心」は `app/` と `config/routes.rb`。「データの形の単一情報源」はマイグレーション実行後の `db/schema.rb` とモデルクラスの両方を見る。

#### `app/controllers`

コントローラクラス（`*_controller.rb`）。ルーティングで選ばれたアクションが実行され、モデルやビューを組み合わせる。`ApplicationController` に共通フィルタやヘルパを置く。アーキテクチャでは HTTP のユースケースごとの入口。

#### `app/models`

Active Record モデル（通常テーブルと 1 対 1）。`ApplicationRecord` を継承する。バリデーション、関連、ドメインロジックの置き場。アーキテクチャではドメインと永続化の境界。

#### `app/views`

ERB などのテンプレート。`layouts/` は共通枠、`articles/` のようにコントローラ名に対応するフォルダにアクション名のファイルを置く。`_` で始まるファイルはパーシャル。Devise を使うと `devise/` の下に認証画面が増える。アーキテクチャではプレゼンテーション層。

#### `app/helpers`

ビュー用のヘルパモジュール（`ApplicationHelper` など）。複雑な表示ロジックをテンプレートから切り出す。アーキテクチャではビュー寄りの再利用。

#### `app/mailers` と `app/views` 以下のメーラーテンプレート

メール送信用クラスと、メール本文のテンプレート（`layouts/mailer` など）。アーキテクチャでは「画面以外の出力チャネル」。

#### `app/jobs`

`ApplicationJob` を継承したジョブ。非同期処理の単位。アーキテクチャではリクエスト／レスポンスの外側で時間のかかる処理を逃がす。

#### `app/assets` と `app/javascript`

スタイルシートや画像（プロジェクトによる）。JavaScript は importmap 構成なら `app/javascript` に配置し、Stimulus コントローラは `javascript/controllers/` に置かれる。このリポジトリでは `application.css` と Stimulus の雛形がある。アーキテクチャではブラウザへ渡す静的資産と薄いクライアント挙動。

#### `config` のよく触るファイル

- `routes.rb` … URL 空間の設計（ルーティング DSL）。
- `database.yml` … 環境別 DB 接続。
- `application.rb` / `environment.rb` … アプリ全体のフレームワーク設定。
- `environments/*.rb` … 開発・本番など環境別の挙動。
- `initializers/*.rb` … 起動時に読み込む追加設定（Gem が指示する設定など）。
- `deploy.yml` など … Kamal 利用時のデプロイ宣言。

アーキテクチャでは「コードではなく設定で差し替える層」がここに集まる。

#### `db`

- `migrate/` … スキーマ変更のバージョン履歴。
- `schema.rb` … 現在のスキーマのまとめ（マイグレーション適用後に更新される）。
- `seeds.rb` … 開発・初期データ投入。

アーキテクチャではモデルが依存する物理スキーマの記録。

#### アーキテクチャとの対応を一文で引くと

- ルーティングとコントローラ … `config/routes.rb` と `app/controllers` が HTTP の境界。
- ドメインと DB … `app/models` と `db/` がデータと整合をとる。
- 表示 … `app/views` と `app/helpers`、およびレイアウトが応答の見た目。
- 横断関心事 … Concern は `app/models/concerns` や `app/controllers/concerns`（必要なら）、認証は Gem と初期設定が絡む。
- 資産とフロント … `app/assets`、`app/javascript` がブラウザ側の補助線。

フレームワークはこの配置を前提にガイドやジェネレータが動くため、「まず標準の場所を見る」ことがリーディングコストを下げる。

### Railsでのデータベースの扱い方

Rails はリレーショナル DB を前提に、接続設定・スキーマのバージョン管理・オブジェクトとしての読み書きをひとつのストーリーで扱う。この節では流れとよくある操作の置き場所を整理する。

#### 接続設定（`config/database.yml`）

環境（`development` / `test` / `production` など）ごとに、アダプタ名（例: `postgresql`）、データベース名、ホスト、ユーザー、パスワードなどを宣言する。Rails 起動時に Active Record がこの設定で接続プールを張る。このリポジトリの AGENTS でも PostgreSQL が前提になっている。

#### スキーマの単一情報源としてのマイグレーションと `schema.rb`

テーブル作成・カラム追加・インデックス・外部キーなどは `db/migrate/` の Ruby ファイルで記述し、`bin/rails db:migrate` で DB に適用する。適用後、`db/schema.rb`（または `db/structure.sql` を使う構成の場合はそちら）が現在のスキーマの写しとして更新される。チームでは「マイグレーションをマージしてから migrate」が基本フローになる。

```ruby
# マイグレーションのイメージ（change メソッド内）
add_column :articles, :published_at, :datetime
add_index :articles, :user_id
```

#### Active Record での読み書き

モデルクラスがテーブルの行に対応する。`find` / `find_by` / `where` チェーンで取得し、`new` + `save` または `create` で挿入し、`update` / `destroy` で更新・削除する。失敗時はバリデーションエラーや例外のどちらかになる（`save!` は失敗時に例外）。

```ruby
# 読み取りの例
Article.find(1)
Article.where(user_id: 1).order(created_at: :desc).limit(10)

# 書き込みの例（バリデーションが通れば true）
article = Article.new(title: "Hi", body: "...", user: current_user)
article.save
```

#### 関連（アソシエーション）と外部キー

`belongs_to` / `has_many` / `has_one` などでテーブル間を宣言し、`user.articles` のように関連経由でアクセスする。マイグレーションで `t.references :user, foreign_key: true` のように外部キー制約を付けると、DB 側でも参照整合性が保たれる。

#### バリデーションとコールバック

`validates` で保存前のルールをモデルに書く。`before_save` などのコールバックで副作用を挟めるが、複雑になると追いにくいのでドメインロジックの置き場を意識する。

#### トランザクション

複数ステップをまとめて成功／失敗させたいときは `ActiveRecord::Base.transaction` ブロックで囲む。失敗時にロールバックされ、データの中途半端な状態を防ぎやすい。

```ruby
ActiveRecord::Base.transaction do
  user.save!
  user.account.create!(balance: 0)
end
```

#### クエリの組み立てと N+1

`includes` / `preload` / `eager_load` で関連をまとめて読み、ループ内で毎回 SQL が走る N+1 を抑える。このリポジトリの `ArticlesController#show` では `@article.comments.includes(:user)` のように関連読み込みを指定している。

#### 生 SQL と `structure.sql`

複雑な集計や DB 独自機能は `find_by_sql` や `connection.execute`、ビューに任せる、などの選択肢がある。PostgreSQL 固有の型や制約を厳密に管理したい場合は `structure.sql` モードを選ぶプロジェクトもある。

#### シードとメンテナンス用タスク

`db/seeds.rb` に開発用の初期データを書き、`bin/rails db:seed` で投入する。本番でのデータ移行はマイグレーションと別タスクに分ける判断が多い。

```bash
# よく使う db 系コマンドの例
bin/rails db:create          # データベースを作成（初回など）
bin/rails db:migrate         # 未適用マイグレーションを実行
bin/rails db:rollback        # 直前のマイグレーションを戻す
bin/rails db:reset           # drop → create → migrate → seed（開発で注意して使う）
bin/rails db:schema:dump     # schema.rb を手元で再生成したいときなど
```

#### まとめ（アーキテクチャとの関係）

DB は「`database.yml` で繋ぎ、`db/migrate` で形を変え、`schema.rb` で現状を共有し、`app/models` の Active Record でアプリから触る」という一本の線になる。コントローラは Strong Parameters とモデルを通じて DB に届き、ビューはモデルの属性を表示する。SQL を意識する頻度は下がるが、インデックスや制約、パフォーマンスのときは DB と向き合う必要がある。

## PostgreSQLデータベースについて

このプロジェクトでは PostgreSQL を使う前提なので、ここでは PostgreSQL を中心に整理する。Rails 側からの触り方は前章の「Railsでのデータベースの扱い方」と重なる部分があるので、本章では「PostgreSQL という製品」としての特徴と基本操作を押さえる。

### PostgreSQLの特徴

PostgreSQL（よく Postgres と略す）は、長い歴史を持つオープンソースのリレーショナルデータベース管理システム（RDBMS）である。ライセンスは PostgreSQL License で、商用・個人を問わず広く使われている。Rails の Active Record とも組み合わせやすく、デプロイ先（クラウドのマネージド、コンテナ、自前サーバー）の選択肢も多い。

#### リレーショナル + 拡張性のある設計

正規化されたテーブルと SQL を中心に据えつつ、独自型・関数・演算子・インデックスを後から拡張する余地が多い。`CREATE EXTENSION pgcrypto` のように拡張機能（`pg_trgm`、`uuid-ossp`、PostGIS など）を有効化して機能を足す文化がある。

#### ACID と MVCC

トランザクションは ACID 特性（原子性・一貫性・独立性・永続性）を満たすことが前提で、複数の読み書きを安全にまとめられる。並行制御には MVCC（多版同時実行制御）を採用しており、読み取りと書き込みが互いをほぼブロックしない。

#### 豊富なデータ型

`integer` / `text` / `boolean` / `timestamp` といった基本型に加え、`json` / `jsonb`、配列型、`uuid`、`numeric`（任意精度）、範囲型（`int4range` 等）など、業務でよく使う型が標準で揃っている。`jsonb` は中身にインデックスも張れる。

#### 強い SQL 表現力

ウィンドウ関数、CTE（`WITH` 句）、再帰クエリ、`UPSERT`（`INSERT ... ON CONFLICT`）、`RETURNING` 節など、複雑な集計や更新を SQL で簡潔に書ける。

#### 整合性とインデックス

外部キー、`CHECK` 制約、ユニーク制約、部分インデックス、式インデックスなど、データ品質を DB 側で守るための仕組みが整う。トリガでイベント駆動の処理も書けるが、過度な利用は読みづらくなる。

#### 運用周辺

論理／物理レプリケーション、ストリーミングレプリケーション、`pg_dump` / `pg_restore` でのバックアップ、Point-In-Time Recovery、`EXPLAIN` / `EXPLAIN ANALYZE` でのプラン確認など、運用の手段が用意されている。マネージド（Amazon RDS / Aurora、Google Cloud SQL、Azure、Supabase など）を選べば運用負担を下げやすい。

#### Rails との相性

Rails のデフォルト想定の DB のひとつであり、`postgresql` アダプタ・ジェネレータ・マイグレーション DSL が `jsonb`、配列型、UUID などを表現できる。本リポジトリでも `config/database.yml` の `adapter: postgresql` を起点に Active Record が接続する。

### PostgreSQLの得意なこと、不得意なこと

製品としての適性も、用途とのマッチングで考えると整理しやすい。

#### 得意なこと

- 正規化された業務データ（記事・コメント・ユーザーのような関連が多いドメイン）の保存と整合性確保。
- 複雑な集計・分析クエリ（CTE・ウィンドウ関数・JOIN を多用するレポート系）。
- 半構造化データの併用（`jsonb` で柔軟なスキーマを部分的に許容しつつ、リレーショナルの強みも残す）。
- 全文検索や類似検索の入口（`pg_trgm`、組み込みの全文検索、PostGIS による地理情報など）。
- 一貫性が重要なシステム（金額計算、在庫、予約のような「途中状態を許せない」ドメイン）。
- 中〜大規模なオンラインサービスのプライマリ DB（適切な設計とインデックスがあれば十分にスケールする）。

#### 不得意なこと（向きにくい場面）

- 1 ノードで秒間百万単位の小さな書き込みを延々と捌く、KVS 的なワークロード（Redis や専用ストレージのほうが素直）。
- 検索エンジン専用機能（複雑なスコアリング・分散検索）を重く使う場面（Elasticsearch / OpenSearch を併用するのが現実的）。
- グラフ探索の深い再帰や巨大グラフの処理（グラフ DB の専用機能を使うほうがよい場合がある）。
- スキーマレスでドキュメント単位のスケールアウトが第一目的の場合（MongoDB などのドキュメント DB が選ばれることもある）。
- 単一ノード前提のままで「何もしなくても無限スケール」する用途（読み取りはレプリカ、書き込みはシャーディングや分割など追加設計が必要）。

PostgreSQL は「まず PostgreSQL に置いて、ボトルネックが見えたら他を足す」スタートが取りやすい DB と言える。

### PostgreSQLの基本的な機能や使い方、コマンド

ここでは Rails から離れ、SQL と CLI の最小ラインをまとめる。Rails の `bin/rails db:*` コマンドは内部でこれらを呼んでいるイメージで読むと位置関係が分かりやすい。

#### CLI（`psql`）の起動と終了

`psql` は PostgreSQL の対話シェル。データベースに接続して SQL を打てる。

```bash
# データベース myapp_development に接続（ユーザー postgres）
psql -U postgres -d myapp_development

# よく使うメタコマンド（psql 内で実行）
# \l        データベース一覧
# \c <db>   データベースを切り替え
# \dt       テーブル一覧
# \d <tbl>  テーブル定義（カラム・インデックス等）
# \du       ユーザー（ロール）一覧
# \q        psql 終了
```

接続情報は環境変数（`PGHOST` / `PGUSER` / `PGPASSWORD` / `PGDATABASE`）でも渡せる。Rails は `config/database.yml` 経由で同等の情報を持っている。

#### データベースとロールの作成

```sql
-- データベース作成（CLI から）
CREATE DATABASE myapp_development;

-- ロール（ユーザー）作成
CREATE ROLE app LOGIN PASSWORD 'secret';

-- データベースの所有権付与
ALTER DATABASE myapp_development OWNER TO app;
```

開発環境では `createdb`（CLI）と `createuser`（CLI）でも同じことができる。

#### テーブル作成と基本制約

```sql
CREATE TABLE articles (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id),
  title       TEXT   NOT NULL,
  body        TEXT   NOT NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT now(),
  updated_at  TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX index_articles_on_user_id ON articles (user_id);
```

実プロジェクトでは Rails のマイグレーションがこの DDL を生成・適用する。SQL を直接書く場面は限定的だが、`schema.rb` を読むときの土台になる。

#### よく使う SQL（CRUD と JOIN）

```sql
-- 取得（JOIN とソート）
SELECT a.id, a.title, u.email
FROM   articles a
JOIN   users u ON u.id = a.user_id
WHERE  a.created_at >= now() - interval '7 days'
ORDER  BY a.created_at DESC
LIMIT  20;

-- 追加
INSERT INTO articles (user_id, title, body)
VALUES (1, 'Hello', 'First post')
RETURNING id;

-- 更新
UPDATE articles SET title = 'Updated' WHERE id = 1;

-- 削除
DELETE FROM articles WHERE id = 1;
```

#### トランザクション

```sql
BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
-- 失敗時は ROLLBACK; で取り消す
```

Rails 側からは `ActiveRecord::Base.transaction` ブロックで同等の制御ができる。

#### インデックスとプラン確認

```sql
-- 部分インデックスや式インデックスも作れる
CREATE INDEX index_articles_published ON articles (created_at)
WHERE  created_at >= now() - interval '90 days';

-- 実行プランの確認（実行はせず推定だけ）
EXPLAIN SELECT * FROM articles WHERE user_id = 1;

-- 実行と統計の取得
EXPLAIN ANALYZE SELECT * FROM articles WHERE user_id = 1;
```

`Seq Scan`（全件走査）が出ている時は WHERE / JOIN 列にインデックスがあるか、データ分布が適切かを疑う。

#### バックアップとリストア

```bash
# 単一データベースのダンプ（テキスト形式）
pg_dump -U postgres -d myapp_development -f dump.sql

# カスタム形式（並列リストア可）
pg_dump -U postgres -d myapp_development -F c -f dump.dump

# リストア
psql -U postgres -d myapp_development -f dump.sql
# または
pg_restore -U postgres -d myapp_development dump.dump
```

#### 拡張機能（必要になったとき）

```sql
-- UUID 生成、暗号関連、類似検索などはこのパターンで足す
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

Rails のマイグレーションでも `enable_extension "pgcrypto"` のように記述できる。

#### ロール・権限の最低限

本番では「アプリ用ロールはアプリのスキーマだけに権限を持つ」「マイグレーション用ロールは DDL を打てる」など分ける運用が多い。`GRANT` / `REVOKE` で細かく付け外しする。

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON articles TO app;
```

#### Rails と PostgreSQL のつなぎを一言で

Rails は `config/database.yml` の設定で `psql` 相当の接続を張り、`db:migrate` がマイグレーション用 DDL を実行し、Active Record が `SELECT` / `INSERT` / `UPDATE` / `DELETE` を組み立てて発行する。`bin/rails dbconsole` で直接 `psql` が開くため、SQL レベルで挙動を確かめたいときに有用である。

## このプロジェクトのコード解説

ここまでで Ruby・Rails・PostgreSQL の輪郭が揃ったので、最後にこのリポジトリのファイルを「ルーティング → モデル → コントローラ → ビュー → スタイル → テスト」の順で読み解く。アーキテクチャ上の役割と、Ruby の文法的なポイントもあわせて触れる。

### ルーティング: `config/routes.rb`

URL 空間の設計図。Devise のルートと、`articles` をネストした `comments` を宣言している。

```ruby 1:19:config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  resources :articles do
    resources :comments, only: %i[create destroy]
  end
end
```

読みどころ。

- `devise_for :users` … 認証関連のルート（サインイン、ログアウト、登録など）を一括で定義。`:users` はシンボルで「`User` モデルに対応」の意味。
- `root "pages#home"` … `/` を `PagesController#home` に割り当てる。
- `resources :articles` … REST 7 アクションをまとめて生成。
- ネストした `resources :comments, only: %i[create destroy]` … `/articles/:article_id/comments` 配下に `create` と `destroy` のみを生やす。`%i[create destroy]` はシンボルの配列リテラル。

文法面では「ブロック付きメソッド呼び出し（`draw do ... end`、`resources do ... end`）」が DSL の根っこになっている。

### モデル: ドメインと永続化

#### `Article`

```ruby 1:12:app/models/article.rb
class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, :body, presence: true

  def editable_by?(user)
    return false if user.nil?

    user_id == user.id
  end
end
```

- `belongs_to :user` / `has_many :comments` … テーブル間の関連を Active Record に宣言。`dependent: :destroy` は記事削除時に紐づくコメントも消す。
- `validates :title, :body, presence: true` … 2 つの属性に「空でないこと」を要求。
- `editable_by?` … 述語メソッド（命名の慣習）。引数 `user` が `nil` のときは早期 `return false`、そうでなければ「id が同じか」で真偽を返す。`user_id == user.id` の左辺は Active Record が DB カラムに対して自動生成したアクセサである。

#### `Comment`

```ruby 1:12:app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user

  validates :body, presence: true

  def deletable_by?(user)
    return false if user.nil?

    user_id == user.id || article.user_id == user.id
  end
end
```

`deletable_by?` は「投稿者本人」または「記事の作者」の二択。`||` は左辺が真ならそこで決まる短絡評価。コメント投稿者と記事作者の両方が削除できる、という認可ルールを 1 行で表している。

#### `User`

```ruby 1:9:app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
```

`devise ...` は Gem が提供するクラスマクロで、シンボルで「有効化するモジュール」を列挙する書き方。`User` は記事とコメントの双方を `has_many` で持つ（モデル末尾参照）。

### コントローラ: HTTP の入口

#### `ApplicationController`

```ruby 1:7:app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
```

すべてのコントローラの親。Rails 8 のデフォルトであるブラウザ制限と etag の取り扱いがここに集約されている。

#### `ArticlesController`

```ruby 1:42:app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_article, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]

  def index
    @articles = Article.order(created_at: :desc)
  end

  def show
    @comments = @article.comments.includes(:user).order(created_at: :asc)
  end

  def new
    @article = current_user.articles.build
  end

  def create
    @article = current_user.articles.build(article_params)

    if @article.save
      redirect_to @article, notice: "Article was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "Article was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, notice: "Article was successfully destroyed."
  end

  private
```

- `before_action ..., except: %i[index show]` … 「閲覧系を除き」ログイン必須。`%i[...]` でシンボル配列を作っている。
- `set_article` で `@article` を共通で取得し、`authorize_owner!` で「自分の記事か」をチェック。3 段階のフィルタが「認証 → 取得 → 認可」の順に並ぶ。
- `index` の `Article.order(created_at: :desc)` は SQL の `ORDER BY ... DESC` を組み立てる。
- `show` の `@article.comments.includes(:user)` は N+1 を避けるためのプリロード。
- `new` の `current_user.articles.build` は「`current_user` の `articles` コレクションに、未保存のインスタンスを 1 件作る」。`user_id` が自動でセットされる。
- `create` / `update` は「成功 → リダイレクト + フラッシュ」「失敗 → 同じテンプレートを 422 で再表示」というパターン。

```ruby 44:59:app/controllers/articles_controller.rb
  private

  def set_article
    @article = Article.find(params[:id])
  end

  def authorize_owner!
    return if @article.editable_by?(current_user)

    redirect_to articles_path, alert: "You are not allowed to modify this article."
  end

  def article_params
    params.require(:article).permit(:title, :body)
  end
end
```

`article_params` は Strong Parameters の定番形。フォーム由来の `params[:article]` から `:title` と `:body` だけを許す。`authorize_owner!` の `return if ...` は早期リターンの慣用句。
`params` は Action Controller が用意したインスタンスメソッド。`ApplicationController` を経由してすべてのコントローラで使える。
中身は `ActionController::Parameters` というハッシュに近いオブジェクトで、Strong Parameters のメソッド（`require` / `permit` など）を持つ。

#### `CommentsController`

```ruby 1:37:app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article

  def create
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @article, notice: "Comment was successfully added."
    else
      redirect_to @article, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @comment = @article.comments.find(params[:id])

    unless @comment.deletable_by?(current_user)
      redirect_to @article, alert: "You are not allowed to delete this comment."
      return
    end

    @comment.destroy
    redirect_to @article, notice: "Comment was successfully deleted."
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
```

ネストルートのため `set_article` で `params[:article_id]` を使う点が `ArticlesController` と異なる。`@article.comments.find(params[:id])` は「その記事に属するコメント」だけを対象にするため、別記事のコメント id を渡されても `RecordNotFound` で守られる。`unless ... return` で「権限がなければ早期離脱」という形を取っている。

### ビュー: ERB と Hotwire 寄りの記法

#### レイアウト `application.html.erb`

```html 1:54:app/views/layouts/application.html.erb
<!DOCTYPE html>
<html lang="en">
  <head>
    <title><%= content_for(:title) || "Ruby Blog" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="application-name" content="Ruby Blog">
    <meta name="mobile-web-app-capable" content="yes">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= yield :head %>

    <%# Enable PWA manifest for installable apps (make sure to enable in config/routes.rb too!) %>
    <%#= tag.link rel: "manifest", href: pwa_manifest_path(format: :json) %>

    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body>
    <header class="top-nav">
      <div class="top-nav__inner">
        <%= link_to "Ruby Blog", root_path, class: "brand" %>
        <nav class="top-nav__links" aria-label="Primary">
          <%= link_to "Articles", articles_path, class: "nav-link" %>
          <% if user_signed_in? %>
            <%= button_to "Log out", destroy_user_session_path, method: :delete, class: "btn btn--ghost btn--small" %>
          <% else %>
            <%= link_to "Sign up", new_user_registration_path, class: "nav-link" %>
            <%= link_to "Sign in", new_user_session_path, class: "nav-link" %>
          <% end %>
        </nav>
      </div>
    </header>

    <main class="shell">
      <div class="flash-stack">
        <% if notice.present? %>
          <div class="flash flash--notice" role="status"><%= notice %></div>
        <% end %>
        <% if alert.present? %>
          <div class="flash flash--alert" role="alert"><%= alert %></div>
        <% end %>
      </div>

      <%= yield %>
    </main>
  </body>
</html>
```

- `content_for(:title) || "Ruby Blog"` … 各テンプレートが `content_for :title, "..."` で積んだ文字列をタイトルにし、未設定ならデフォルト。
- `csrf_meta_tags` / `csp_meta_tag` … セキュリティ用の meta タグ。CSRF トークンの埋め込みは Rails のデフォルト保護の一部。
- `stylesheet_link_tag` / `javascript_importmap_tags` … 資産配信のヘルパ。`data-turbo-track` は Turbo がアセット差し替えを検出するためのフック。
- `user_signed_in?` … Devise 由来のヘルパ。ナビでサインイン状態に応じた表示を分岐。
- `notice` / `alert` … フラッシュ。`redirect_to ..., notice: ...` の対になる。
- `<%= yield %>` … 各アクションのテンプレート本体がここに差し込まれる。

#### 一覧 `articles/index.html.erb`

```html 1:23:app/views/articles/index.html.erb
<% content_for :title, "Articles — Ruby Blog" %>

<h1 class="page-title">Articles</h1>

<% if user_signed_in? %>
  <p class="toolbar">
    <%= link_to "New article", new_article_path, class: "btn btn--primary btn--small" %>
  </p>
<% end %>

<% if @articles.any? %>
  <ul class="article-card-list">
    <% @articles.each do |article| %>
      <li>
        <%= link_to article_path(article), class: "article-card" do %>
          <h2 class="article-card__title"><%= article.title %></h2>
        <% end %>
      </li>
    <% end %>
  </ul>
<% else %>
  <div class="empty-state">No articles yet.</div>
<% end %>
```

`link_to` にブロックを渡すと、`<a>` タグの中身を自由な HTML にできる。`@articles.each do |article| ... end` は Ruby のブロックそのもので、ループ内で各要素にアクセスする。

#### 記事詳細 `articles/show.html.erb`

```html 1:48:app/views/articles/show.html.erb
<% content_for :title, "#{@article.title} — Ruby Blog" %>

<p class="back-row"><%= link_to "← Back to articles", articles_path, class: "link-muted" %></p>

<article class="panel glass">
  <h1 class="page-title"><%= @article.title %></h1>
  <div class="article-body">
    <%= simple_format(@article.body) %>
  </div>

  <% if @article.editable_by?(current_user) %>
    <div class="toolbar">
      <%= link_to "Edit article", edit_article_path(@article), class: "btn btn--ghost btn--small" %>
      <%= button_to "Delete article", article_path(@article), method: :delete, class: "btn btn--danger btn--small", form: { data: { turbo_confirm: "Are you sure?" } } %>
    </div>
  <% end %>
</article>

<section aria-labelledby="comments-heading">
  <h2 id="comments-heading" class="section-title">Comments</h2>

  <% @comments.each do |comment| %>
    <div class="comment-card">
      <div class="article-body"><%= simple_format(comment.body) %></div>
      <p class="meta"><%= comment.user.email %> · <%= l(comment.created_at, format: :short) %></p>
      <% if comment.deletable_by?(current_user) %>
        <%= button_to "Delete comment", article_comment_path(@article, comment), method: :delete, class: "btn btn--danger btn--small", form: { data: { turbo_confirm: "Delete this comment?" } } %>
      <% end %>
    </div>
  <% end %>

  <% if user_signed_in? %>
    <h3 class="subsection-title">Add a comment</h3>
    <div class="panel panel--tight glass">
      <%= form_with model: [@article, Comment.new], local: true do |form| %>
        <div class="field">
          <%= form.label :body, "Comment" %>
          <%= form.text_area :body, rows: 5 %>
        </div>
        <div>
          <%= form.submit "Post comment", class: "btn btn--primary" %>
        </div>
      <% end %>
    </div>
  <% else %>
    <p class="meta"><%= link_to "Sign in", new_user_session_path %> to comment.</p>
  <% end %>
</section>
```

- `simple_format(...)` … 改行を `<p>` に変換しつつ HTML エスケープしてくれる、本文表示向きヘルパ。
- `editable_by?` / `deletable_by?` … モデルの述語メソッドをそのまま画面の出し分けに使う。コントローラと同じルールがビュー側でも一貫する。
- `button_to "...", ..., method: :delete, form: { data: { turbo_confirm: "..." } }` … 削除用フォーム + Turbo の確認ダイアログ。ハッシュをネストして `data-turbo-confirm` 属性を生成する。
- `form_with model: [@article, Comment.new]` … ネストしたリソースから URL（`/articles/:id/comments`）と HTTP メソッド（`POST`）を推測する。`Comment.new` は未保存の新規インスタンスで、フォームの「対象」になる。
- `l(comment.created_at, format: :short)` … I18n の日時整形ヘルパ。

- `article_comment_path` は ルーティング DSL の結果として Rails が生成するメソッド。
- 定義の元は `config/routes.rb`。名前の一覧は `bin/rails routes` で確認するのが確実。

#### パーシャル `articles/_form.html.erb`

```html 1:26:app/views/articles/_form.html.erb
<% if article.errors.any? %>
  <div class="field-error-box" role="alert">
    <h2><%= pluralize(article.errors.count, "error") %> prevented this article from being saved:</h2>
    <ul>
      <% article.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>

<%= form_with model: article do |form| %>
  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>

  <div class="field">
    <%= form.label :body %>
    <%= form.text_area :body, rows: 12 %>
  </div>

  <div>
    <%= form.submit class: "btn btn--primary" %>
  </div>
<% end %>
```

`new` と `edit` の両方から `render "form", locals: { article: @article }` の形で再利用する想定。`form_with model: article` は新規／更新の URL とメソッドをモデルの状態から決める。`pluralize(n, "error")` は単複処理を任せる便利ヘルパ。

### スタイル: `app/assets/stylesheets/application.css`

`:root` に CSS 変数（色・余白・角丸・影・フォント）を集中させ、コンポーネントのクラス（`.glass`、`.btn`、`.shell` など）から `var(--...)` で参照する設計。命名は BEM に近い（`btn--primary` のように修飾子を `--` でつなぐ）。

```css 5:48:app/assets/stylesheets/application.css
:root {
  color-scheme: light;

  --bg-0: #faf7f2;
  --bg-1: #f3ebe2;
  --bg-gradient: linear-gradient(165deg, var(--bg-0) 0%, var(--bg-1) 55%, #ebe4db 100%);

  --surface: rgba(255, 255, 255, 0.68);
  --surface-strong: rgba(255, 255, 255, 0.82);
  --surface-border: rgba(255, 255, 255, 0.75);
  --stroke: rgba(45, 41, 37, 0.1);

  --text: #2a2522;
  --text-muted: #6f6761;

  --accent: #b8622a;
  --accent-hover: #9e5222;
  --accent-soft: rgba(184, 98, 42, 0.14);
  --accent-ring: rgba(184, 98, 42, 0.35);

  --danger: #b33a3a;
  --danger-soft: rgba(179, 58, 58, 0.1);

  --radius-sm: 8px;
  --radius: 12px;
  --radius-lg: 18px;

  --shadow-sm: 0 1px 2px rgba(42, 37, 34, 0.06), 0 8px 24px rgba(42, 37, 34, 0.06);
  --shadow-md: 0 4px 12px rgba(42, 37, 34, 0.08), 0 18px 40px rgba(42, 37, 34, 0.07);

  --blur-glass: 14px;

  --font-sans: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;

  --space-1: 0.35rem;
  --space-2: 0.55rem;
  --space-3: 0.9rem;
  --space-4: 1.35rem;
  --space-5: 2rem;
  --space-6: 2.75rem;

  --content-width: 42rem;
  --wide-width: min(72rem, calc(100vw - 2rem));
}
```

```css 60:69:app/assets/stylesheets/application.css
body {
  margin: 0;
  min-height: 100vh;
  font-family: var(--font-sans);
  font-size: 1rem;
  line-height: 1.65;
  color: var(--text);
  background: var(--bg-gradient);
  background-attachment: fixed;
}
```

`body` は背景・フォント・配色を変数経由で決める。`.shell` で本文幅を `min()` を使って画面に応じて狭めるなど、レスポンシブの基礎が `:root` のトークンに集まっている。

#### コンポーネント用クラスの例（レイアウト・パネル・ボタン）

ビューでは `class="panel glass"` のように複数クラスを並べ、ブロック（`.panel`）と修飾子（`.panel--tight`）や見た目用（`.glass`）を組み合わせる。次はその定義の抜粋である。

```css 87:104:app/assets/stylesheets/application.css
.shell {
  width: min(var(--content-width), calc(100vw - 2rem));
  margin-inline: auto;
  padding-block: var(--space-5);
}

.shell--wide {
  width: var(--wide-width);
}

.glass {
  background: var(--surface);
  border: 1px solid var(--surface-border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  backdrop-filter: blur(var(--blur-glass));
  -webkit-backdrop-filter: blur(var(--blur-glass));
}
```

`.shell` は本文カラムの幅と余白。`.glass` は半透明面とぼかしで「ガラス風」のカード見た目を与える。

```css 203:210:app/assets/stylesheets/application.css
.panel {
  padding: var(--space-5);
  margin-bottom: var(--space-4);
}

.panel--tight {
  padding: var(--space-4);
}
```

`.panel` は余白の箱。`--tight` は修飾子でパディングだけ詰める（BEM 風の `--` 連結）。

```css 348:404:app/assets/stylesheets/application.css
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-sm);
  font: inherit;
  font-weight: 600;
  cursor: pointer;
  border: 1px solid transparent;
  text-decoration: none;
  transition: transform 0.15s ease, box-shadow 0.15s ease, background 0.15s ease, border-color 0.15s ease;
}

.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.btn--primary {
  background: linear-gradient(180deg, #c9753b 0%, var(--accent) 100%);
  color: #fff;
  box-shadow: 0 2px 8px rgba(184, 98, 42, 0.35);
}

.btn--primary:hover {
  background: linear-gradient(180deg, #d48248 0%, var(--accent-hover) 100%);
  transform: translateY(-1px);
  box-shadow: 0 6px 18px rgba(184, 98, 42, 0.35);
}

.btn--ghost {
  background: rgba(255, 255, 255, 0.55);
  border-color: rgba(42, 37, 34, 0.12);
  color: var(--text);
}

.btn--ghost:hover {
  background: var(--accent-soft);
  border-color: rgba(184, 98, 42, 0.25);
}

.btn--danger {
  background: rgba(179, 58, 58, 0.08);
  border-color: rgba(179, 58, 58, 0.35);
  color: #7a2828;
}

.btn--danger:hover {
  background: rgba(179, 58, 58, 0.14);
}

.btn--small {
  padding: var(--space-2) var(--space-3);
  font-size: 0.88rem;
}
```

`.btn` が共通のボタン枠で、`--primary` / `--ghost` / `--danger` が配色とホバー、`--small` がサイズを変える。ビューでは `class="btn btn--primary btn--small"` のように複数修飾子を重ねる。

### テスト: `spec/requests/comments_spec.rb`

リクエストスペックは「実 URL に HTTP を投げ、ステータス・リダイレクト先・DB の差分を見る」層のテスト。Devise の `sign_in` ヘルパで、`authenticate_user!` を満たす擬似ログインを作る。

```ruby 22:42:spec/requests/comments_spec.rb
  describe "POST /articles/:article_id/comments" do
    it "redirects guests to sign in" do
      post article_comments_path(article), params: { comment: { body: "Nice" } }

      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a comment when signed in" do
      sign_in commenter

      expect do
        post article_comments_path(article), params: { comment: { body: "Nice post" } }
      end.to change(Comment, :count).by(1)

      expect(response).to redirect_to(article_path(article))
      comment = Comment.last
      expect(comment.user_id).to eq(commenter.id)
      expect(comment.article_id).to eq(article.id)
      expect(comment.body).to eq("Nice post")
    end
  end
```

```ruby 44:81:spec/requests/comments_spec.rb
  describe "DELETE /articles/:article_id/comments/:id" do
    let!(:comment) do
      Comment.create!(article: article, user: commenter, body: "Hello")
    end

    it "does not allow a stranger to delete" do
      stranger = User.create!(
        email: "stranger-#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
      sign_in stranger

      expect do
        delete article_comment_path(article, comment)
      end.not_to change(Comment, :count)

      expect(response).to redirect_to(article_path(article))
    end

    it "allows the commenter to delete" do
      sign_in commenter

      expect do
        delete article_comment_path(article, comment)
      end.to change(Comment, :count).by(-1)

      expect(response).to redirect_to(article_path(article))
    end

    it "allows the article author to delete" do
      sign_in author
```

テスト自体も Ruby のブロック文化に乗っている。`describe`／`it` はブロックを取る DSL、`expect do ... end.to change(Comment, :count).by(1)` は「ブロックの実行前後で `Comment.count` が +1 になる」ことを検証するマッチャ。`let` は遅延評価されるヘルパで、必要になったときに 1 度だけ作られる。

#### 補足

このプロジェクトの `spec/requests/comments_spec.rb` で使っているのは GUI（ブラウザ）テストではなく、HTTP レイヤの結合テストに近いものです。

`type: :request` のリクエストスペックは、Rails の テスト用ハーネス がアプリ内部で HTTP リクエストを直接組み立てて、ルーティング → コントローラ → モデル → テンプレート（必要なら）まで通します。

ブラウザは起動しない
サーバプロセスは別途立てない
JavaScript も実行されない
画面のクリックやフォーム入力もしない
代わりに、コード上で `post article_comments_path(...)` のように呼び、`response`（HTTP レスポンス）と DB の状態を検証します。`spec/requests/comments_spec.rb` でやっているのもこの形です。

つまり「処理の結合テスト相当」が近い表現で、より厳密に言うと 「Rack ミドルウェア + ルーティング + コントローラ + モデル を通した、HTTP の入口から出口までの結合テスト」 です。

### 全体のつなぎ（アーキテクチャとの対応）

- ルーティング … `config/routes.rb` で「Articles を中心にコメントをぶら下げる」という URL 設計を 1 ファイルで読み切れる。
- ドメインと永続化 … `Article`・`Comment`・`User` がそれぞれの関連と認可ロジックを担う。`editable_by?` / `deletable_by?` がコントローラとビューで一貫して使われ、ロジックがモデル側に寄っている。
- HTTP の入口 … `ArticlesController` と `CommentsController` が「認証 → 取得 → 認可 → 実処理」の順でフィルタを並べ、Strong Parameters と `redirect_to` / `render :status` のお決まりの形で応答を組む。
- プレゼンテーション … レイアウトとアクションテンプレート、パーシャルが ERB で重なり、`form_with` や `button_to` で HTML フォームを宣言的に組み立てる。
- スタイル … `:root` のトークンを起点に、再利用しやすい命名でコンポーネント単位に書く構成。
- テスト … リクエストスペックが「URL → 認可 → DB 影響 → リダイレクト」を一気通貫に検証し、回帰防止に厚めの層を用意している。

これらは全て、これまでの章で見てきた Ruby・Rails・PostgreSQL の概念の組み合わせで構成されている。コードを読んでいて迷ったら、対応する概念の章に戻ると、書き方の意味がつなぎ直しやすい。
