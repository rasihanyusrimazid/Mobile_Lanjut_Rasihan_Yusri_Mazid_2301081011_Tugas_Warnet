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
        // Get all books
        $sql = "SELECT * FROM buku ORDER BY kode_buku DESC";
        $stmt = $db->prepare($sql);
        $stmt->execute();
        $books = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'data' => $books
        ]);
        break;

    case 'POST':
        // Add new book
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Debug: Print received data
        error_log(print_r($data, true));

        // Validate required fields
        $required_fields = ['kode_buku', 'judul', 'pengarang', 'penerbit', 'tahun'];
        foreach($required_fields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                echo json_encode([
                    'success' => false,
                    'message' => "Field '$field' is required"
                ]);
                exit();
            }
        }

        // Insert book with url_gambar
        $sql = "INSERT INTO buku (kode_buku, judul, pengarang, penerbit, tahun, url_gambar) 
                VALUES (:kode_buku, :judul, :pengarang, :penerbit, :tahun, :url_gambar)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':kode_buku' => $data['kode_buku'],
                ':judul' => $data['judul'],
                ':pengarang' => $data['pengarang'],
                ':penerbit' => $data['penerbit'],
                ':tahun' => $data['tahun'],
                ':url_gambar' => $data['url_gambar'] ?? null // Optional field
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Book added successfully',
                'kode_buku' => $data['kode_buku']
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add book: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        // Update book
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['kode_buku'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Book code is required'
            ]);
            exit();
        }

        $sql = "UPDATE buku 
                SET judul = :judul, 
                    pengarang = :pengarang,
                    penerbit = :penerbit,
                    tahun = :tahun,
                    url_gambar = :url_gambar
                WHERE kode_buku = :kode_buku";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':kode_buku' => $data['kode_buku'],
                ':judul' => $data['judul'],
                ':pengarang' => $data['pengarang'],
                ':penerbit' => $data['penerbit'],
                ':tahun' => $data['tahun'],
                ':url_gambar' => $data['url_gambar'] ?? null // Optional field
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Book updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update book: ' . $e->getMessage()
            ]);
        }
        break;

    case 'DELETE':
        // Delete book (no changes needed for DELETE)
        if (!isset($_GET['kode_buku'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Book code is required'
            ]);
            exit();
        }

        // Check if book is still borrowed
        $checkSql = "SELECT COUNT(*) FROM peminjaman WHERE buku = :kode_buku";
        $checkStmt = $db->prepare($checkSql);
        $checkStmt->execute([':kode_buku' => $_GET['kode_buku']]);
        $count = $checkStmt->fetchColumn();

        if ($count > 0) {
            echo json_encode([
                'success' => false,
                'message' => 'Buku tidak dapat dihapus karena masih ada data peminjaman'
            ]);
            exit();
        }

        $sql = "DELETE FROM buku WHERE kode_buku = :kode_buku";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':kode_buku' => $_GET['kode_buku']]);
            echo json_encode([
                'success' => true,
                'message' => 'Book deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete book: ' . $e->getMessage()
            ]);
        }
        break;
}

// Close database connection
$db = null;
?>