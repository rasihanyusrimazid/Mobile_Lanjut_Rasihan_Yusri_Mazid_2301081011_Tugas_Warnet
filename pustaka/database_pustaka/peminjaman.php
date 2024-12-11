<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
$host = 'localhost';
$dbname = 'pustaka_2301081011';
$username = 'root';
$password = '';

// Create database connection
try {
    $db = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die(json_encode([
        'success' => false,
        'message' => 'Connection failed: ' . $e->getMessage()
    ]));
}

// Get request method
$method = $_SERVER['REQUEST_METHOD'];

// Handle different HTTP methods
switch($method) {
    case 'GET':
        // Get all loans with member and book details
        $sql = "SELECT p.*, a.nama as nama_anggota, b.judul as judul_buku 
                FROM peminjaman p 
                LEFT JOIN anggota a ON p.anggota = a.id 
                LEFT JOIN buku b ON p.buku = b.kode_buku 
                ORDER BY p.id DESC";
        
        try {
            $stmt = $db->prepare($sql);
            $stmt->execute();
            $loans = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'success' => true,
                'data' => $loans
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Error fetching loans: ' . $e->getMessage()
            ]);
        }
        break;

    case 'POST':
        // Add new loan
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validate required fields
        $required_fields = ['tanggal_pinjam', 'tanggal_kembali', 'anggota', 'buku'];
        foreach($required_fields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                echo json_encode([
                    'success' => false,
                    'message' => "Field '$field' is required"
                ]);
                exit();
            }
        }

        // Check if book is available
        $checkSql = "SELECT COUNT(*) FROM peminjaman 
                    WHERE buku = :buku 
                    AND tanggal_kembali >= CURRENT_DATE()";
        $checkStmt = $db->prepare($checkSql);
        $checkStmt->execute([':buku' => $data['buku']]);
        $count = $checkStmt->fetchColumn();

        if ($count > 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Buku sedang dipinjam'
            ]);
            exit();
        }

        // Insert loan
        $sql = "INSERT INTO peminjaman (tanggal_pinjam, tanggal_kembali, anggota, buku) 
                VALUES (:tanggal_pinjam, :tanggal_kembali, :anggota, :buku)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':tanggal_pinjam' => $data['tanggal_pinjam'],
                ':tanggal_kembali' => $data['tanggal_kembali'],
                ':anggota' => $data['anggota'],
                ':buku' => $data['buku']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Loan added successfully',
                'id' => $db->lastInsertId()
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add loan: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        // Update loan
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Loan ID is required'
            ]);
            exit();
        }

        $sql = "UPDATE peminjaman 
                SET tanggal_pinjam = :tanggal_pinjam,
                    tanggal_kembali = :tanggal_kembali,
                    anggota = :anggota,
                    buku = :buku
                WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':id' => $data['id'],
                ':tanggal_pinjam' => $data['tanggal_pinjam'],
                ':tanggal_kembali' => $data['tanggal_kembali'],
                ':anggota' => $data['anggota'],
                ':buku' => $data['buku']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Loan updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update loan: ' . $e->getMessage()
            ]);
        }
        break;

    case 'DELETE':
        if (!isset($_GET['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Loan ID is required'
            ]);
            exit();
        }

        $sql = "DELETE FROM peminjaman WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Loan deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete loan: ' . $e->getMessage()
            ]);
        }
        break;
}

// Close database connection
$db = null;
?>