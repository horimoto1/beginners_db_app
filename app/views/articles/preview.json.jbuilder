if @text
  json.markdown %(<div class="content">#{markdown(@text)}</div>)
else
  json.markdown "パラメータがありません"
end
