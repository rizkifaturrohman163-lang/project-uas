<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *'); 
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, POST');


$connect = mysqli_connect('localhost', 'root', '', 'kedelai');

// Cek koneksi database jika gagal
if (!$connect) {
    echo json_encode(array('status' => 'gagal', 'message' => 'Koneksi database gagal: ' . mysqli_connect_error()));
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $sql = 'SELECT * FROM catatan_kedelai ORDER BY id DESC'; 
    $result = mysqli_query($connect, $sql);
    
    $data = array();
    if ($result) {
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
    }
    echo json_encode($data);

} elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);

    $nominal = isset($input['nominal']) ? mysqli_real_escape_string($connect, $input['nominal']) : '';
    $kategori = isset($input['kategori']) ? mysqli_real_escape_string($connect, $input['kategori']) : '';

    if (empty($nominal) || empty($kategori)) {
        echo json_encode(array('status' => 'gagal', 'message' => 'Kuantitas atau kategori tidak boleh kosong'));
        exit();
    }

    
    $sql = "INSERT INTO catatan_kedelai (nominal, kategori) VALUES ('$nominal', '$kategori')";
    $result = mysqli_query($connect, $sql);

    if ($result) {
        echo json_encode(array('status' => 'sukses', 'message' => 'Data stok berhasil ditambahkan'));
    } else {
        echo json_encode(array('status' => 'gagal', 'message' => mysqli_error($connect)));
    }
}
?>