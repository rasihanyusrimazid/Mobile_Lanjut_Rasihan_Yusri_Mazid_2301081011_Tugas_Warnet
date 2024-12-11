<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = 'localhost';
$dbname = 'pustaka_2301081011';
$username = 'root';
$password = '';

try {
    $db = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $e->getMessage()
    ]));
}

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['id'])) {
            // Get specific return
            $sql = "SELECT p.*, pm.tanggal_pinjam, pm.tanggal_kembali, 
                    a.nama as nama_anggota, b.judul as judul_buku 
                    FROM pengembalian p 
                    LEFT JOIN peminjaman pm ON p.peminjaman = pm.id 
                    LEFT JOIN anggota a ON pm.anggota = a.id 
                    LEFT JOIN buku b ON pm.buku = b.kode_buku 
                    WHERE p.id = :id";
            $stmt = $db->prepare($sql);
            $stmt->execute([':id' => $_GET['id']]);
            $return = $stmt->fetch(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $return
            ]);
        } else {
            // Get all returns
            $sql = "SELECT p.*, pm.tanggal_pinjam, pm.tanggal_kembali, 
                    a.nama as nama_anggota, b.judul as judul_buku 
                    FROM pengembalian p 
                    LEFT JOIN peminjaman pm ON p.peminjaman = pm.id 
                    LEFT JOIN anggota a ON pm.anggota = a.id 
                    LEFT JOIN buku b ON pm.buku = b.kode_buku 
                    ORDER BY p.id DESC";
            $stmt = $db->prepare($sql);
            $stmt->execute();
            $returns = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $returns
            ]);
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);
        
        if (!isset($data['peminjaman']) || !isset($data['tanggal_dikembalikan'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Required fields are missing'
            ]);
            exit();
        }

        // Calculate late days and fine
        $sql = "SELECT tanggal_kembali FROM peminjaman WHERE id = :id";
        $stmt = $db->prepare($sql);
        $stmt->execute([':id' => $data['peminjaman']]);
        $peminjaman = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $tanggal_kembali = new DateTime($peminjaman['tanggal_kembali']);
        $tanggal_dikembalikan = new DateTime($data['tanggal_dikembalikan']);
        $selisih = $tanggal_dikembalikan->diff($tanggal_kembali);
        
        $terlambat = $tanggal_dikembalikan > $tanggal_kembali ? $selisih->days : 0;
        $denda = $terlambat * 1000; // Denda Rp 1.000 per hari

        $sql = "INSERT INTO pengembalian (tanggal_dikembalikan, terlambat, denda, peminjaman) 
                VALUES (:tanggal_dikembalikan, :terlambat, :denda, :peminjaman)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':tanggal_dikembalikan' => $data['tanggal_dikembalikan'],
                ':terlambat' => $terlambat,
                ':denda' => $denda,
                ':peminjaman' => $data['peminjaman']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Return added successfully',
                'id' => $db->lastInsertId()
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add return: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Return ID is required'
            ]);
            exit();
        }

        // Recalculate late days and fine
        $sql = "SELECT tanggal_kembali FROM peminjaman WHERE id = :id";
        $stmt = $db->prepare($sql);
        $stmt->execute([':id' => $data['peminjaman']]);
        $peminjaman = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $tanggal_kembali = new DateTime($peminjaman['tanggal_kembali']);
        $tanggal_dikembalikan = new DateTime($data['tanggal_dikembalikan']);
        $selisih = $tanggal_dikembalikan->diff($tanggal_kembali);
        
        $terlambat = $tanggal_dikembalikan > $tanggal_kembali ? $selisih->days : 0;
        $denda = $terlambat * 1000;

        $sql = "UPDATE pengembalian 
                SET tanggal_dikembalikan = :tanggal_dikembalikan,
                    terlambat = :terlambat,
                    denda = :denda,
                    peminjaman = :peminjaman
                WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':id' => $data['id'],
                ':tanggal_dikembalikan' => $data['tanggal_dikembalikan'],
                ':terlambat' => $terlambat,
                ':denda' => $denda,
                ':peminjaman' => $data['peminjaman']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Return updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update return: ' . $e->getMessage()
            ]);
        }
        break;

    case 'DELETE':
        if (!isset($_GET['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Return ID is required'
            ]);
            exit();
        }

        $sql = "DELETE FROM pengembalian WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Return deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete return: ' . $e->getMessage()
            ]);
        }
        break;
}

$db = null;
?>