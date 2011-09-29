<html>
<head>
</head>

<body>
<table>
<tr><th>id</th><th>name</th><th>artist</th><th>preview url</th><th>album img</th></tr>
%for t in tracks:
  <tr>
    <td>{{t['id']}}</td>
    <td>{{t['name']}}</td>
    <td>{{t['artist']}}</td>
    <td>{{t['preview_url']}}</td>
    <td>{{t['album_img']}}</td>
  </tr>
%end
</table>
</body>
</html>
