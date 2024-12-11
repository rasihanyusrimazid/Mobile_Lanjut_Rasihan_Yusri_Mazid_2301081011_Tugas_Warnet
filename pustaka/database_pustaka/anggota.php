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
        // Get all members or specific member
        if (isset($_GET['id'])) {
            $sql = "SELECT * FROM anggota WHERE id = :id";
            $stmt = $db->prepare($sql);
            $stmt->execute([':id' => $_GET['id']]);
            $member = $stmt->fetch(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $member
            ]);
        } else {
            $sql = "SELECT * FROM anggota ORDER BY id DESC";
            $stmt = $db->prepare($sql);
            $stmt->execute();
            $members = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            echo json_encode([
                'success' => true,
                'data' => $members
            ]);
        }
        break;

    case 'POST':
        // Add new member
        $data = json_decode(file_get_contents("php://input"), true);
        
        // Validate required fields
        $required_fields = ['nim', 'nama', 'alamat', 'jenis_kelamin'];
        foreach($required_fields as $field) {
            if (!isset($data[$field]) || empty($data[$field])) {
                echo json_encode([
                    'success' => false,
                    'message' => "Field '$field' is required"
                ]);
                exit();
            }
        }

        // Validate jenis_kelamin
        if (!in_array($data['jenis_kelamin'], ['L', 'P'])) {
            echo json_encode([
                'success' => false,
                'message' => "Jenis kelamin must be 'L' or 'P'"
            ]);
            exit();
        }

        // Insert member
        $sql = "INSERT INTO anggota (nim, nama, alamat, jenis_kelamin) 
                VALUES (:nim, :nama, :alamat, :jenis_kelamin)";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':nim' => $data['nim'],
                ':nama' => $data['nama'],
                ':alamat' => $data['alamat'],
                ':jenis_kelamin' => $data['jenis_kelamin']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Member added successfully',
                'id' => $db->lastInsertId()
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to add member: ' . $e->getMessage()
            ]);
        }
        break;

    case 'PUT':
        // Update member
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Member ID is required'
            ]);
            exit();
        }

        // Validate jenis_kelamin if provided
        if (isset($data['jenis_kelamin']) && !in_array($data['jenis_kelamin'], ['L', 'P'])) {
            echo json_encode([
                'success' => false,
                'message' => "Jenis kelamin must be 'L' or 'P'"
            ]);
            exit();
        }

        $sql = "UPDATE anggota 
                SET nim = :nim,
                    nama = :nama,
                    alamat = :alamat,
                    jenis_kelamin = :jenis_kelamin
                WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([
                ':id' => $data['id'],
                ':nim' => $data['nim'],
                ':nama' => $data['nama'],
                ':alamat' => $data['alamat'],
                ':jenis_kelamin' => $data['jenis_kelamin']
            ]);

            echo json_encode([
                'success' => true,
                'message' => 'Member updated successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to update member: ' . $e->getMessage()
            ]);
        }
        break;

    case 'DELETE':
        if (!isset($_GET['id'])) {
            echo json_encode([
                'success' => false,
                'message' => 'Member ID is required'
            ]);
            exit();
        }

        $sql = "DELETE FROM anggota WHERE id = :id";
        $stmt = $db->prepare($sql);
        
        try {
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode([
                'success' => true,
                'message' => 'Member deleted successfully'
            ]);
        } catch(PDOException $e) {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to delete member: ' . $e->getMessage()
            ]);
        }
        break;
}

$db = null;
?>
