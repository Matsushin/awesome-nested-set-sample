initialize = ->
  $('#jstree_categories').jstree({
    'core' : {
      'check_callback' : true,
      'data' :  {
        'url' : (node) ->
          return 'categories.json' # GET /categoris.json を実行する
      }
    },
    "plugins" : [ "dnd" ]
  })

  # 選択されているノードの子として新しいノードを作成する
  $('.js-create-category').on 'click', ->
    jstree = $('#jstree_categories').jstree(true) # jstreeオブジェクトを取得
    selected = jstree.get_selected()   # 選択されているカテゴリを取得
    return false if (!selected.length) # 選択されていない場合何もしないで終了
    selected = selected[0]  # 複数選択もあるのでselectedは配列なので、0番目を取得

    # POST /categories.json
    $.ajax({
      'type'    : 'POST',
      'data'    : { 'category' : { 'name' : 'New node', 'parent_id' : selected } },
      'url'     : '/categories.json',
      'success' : (res) ->
        selected = jstree.create_node(selected, res)
        jstree.edit(selected) if (selected)
    })


  # 選択されているノードの名前を変更する
  $('.js-rename-category').on 'click', ->
    jstree = $('#jstree_categories').jstree(true)
    selected = jstree.get_selected()
    return false if (!selected.length)

    selected = selected[0]
    jstree.edit(selected)

  # ノードの名前の変更が確定されたときに呼ばれるイベント
  $('#jstree_categories').on 'rename_node.jstree', (e, obj) ->
    id = obj.node.id
    renamed_name = obj.text

    # PATCH /categories/id.json
    $.ajax({
      'type'    : 'PATCH',
      'data'    : { 'category' : { 'name' : renamed_name } },
      'url'     : "/categories/#{id}.json"
    })


  # 選択されているノードを削除する
  $('.js-delete-category').on 'click', ->
    jstree = $('#jstree_categories').jstree(true)
    selected = jstree.get_selected()
    return false if (!selected.length)

    selected = selected[0]
    id = selected

    # DELETE /categories/id.json
    $.ajax({
      'type'    : 'DELETE',
      'url'     : "/categories/#{id}.json",
      'success' : ->
        jstree.delete_node(selected)
    })

  # カテゴリを移動させたときに呼ばれるイベント
  $('#jstree_categories').on "move_node.jstree", (e, node) ->
    id            = node.node.id
    parent_id     = node.parent
    new_position  = node.position

    # PATCH /categories/id.json
    $.ajax({
      'type'    : 'PATCH',
      'data'    : { 'category' : { 'parent_id' : parent_id, 'new_position' : new_position } },
      'url'     : "/categories/#{id}.json"
    })

$(document).on 'ready page:load', ->
  initialize() if ($('.categories').is('*'))