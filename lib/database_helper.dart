import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class EmergencyReport {
  final String id;
  final String reporterName;
  final String reportType;
  final String location;
  final String timeAgo;
  final String distance;
  final String description;
  final int iconCodePoint; // Store icon as integer code point
  final int iconBgColorValue; // Store color as integer value
  final int statusColorValue; // Store color as integer value
  final String status;

  EmergencyReport({
    required this.id,
    required this.reporterName,
    required this.reportType,
    required this.location,
    required this.timeAgo,
    required this.distance,
    required this.description,
    required this.iconCodePoint,
    required this.iconBgColorValue,
    required this.statusColorValue,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterName': reporterName,
      'reportType': reportType,
      'location': location,
      'timeAgo': timeAgo,
      'distance': distance,
      'description': description,
      'iconCodePoint': iconCodePoint,
      'iconBgColorValue': iconBgColorValue,
      'statusColorValue': statusColorValue,
      'status': status,
    };
  }

  factory EmergencyReport.fromMap(Map<String, dynamic> map) {
    return EmergencyReport(
      id: map['id'],
      reporterName: map['reporterName'],
      reportType: map['reportType'],
      location: map['location'],
      timeAgo: map['timeAgo'],
      distance: map['distance'],
      description: map['description'],
      iconCodePoint: map['iconCodePoint'],
      iconBgColorValue: map['iconBgColorValue'],
      statusColorValue: map['statusColorValue'],
      status: map['status'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'siren_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports(
        id TEXT PRIMARY KEY,
        reporterName TEXT,
        reportType TEXT,
        location TEXT,
        timeAgo TEXT,
        distance TEXT,
        description TEXT,
        iconCodePoint INTEGER,
        iconBgColorValue INTEGER,
        statusColorValue INTEGER,
        status TEXT
      )
    ''');

    // Insert mock data
    await _insertMockData(db);
  }

  Future<void> _insertMockData(Database db) async {
    List<EmergencyReport> mockReports = [
      EmergencyReport(
        id: '1',
        reporterName: 'Budi Santoso',
        reportType: 'Kecelakaan Lalu Lintas',
        location: 'Jl. Raya Gunungpati No. 12',
        timeAgo: 'Baru saja',
        distance: '0.8 km',
        description: 'Tabrakan motor dengan mobil, 1 korban luka ringan di kaki.',
        iconCodePoint: Icons.car_crash_outlined.codePoint,
        iconBgColorValue: const Color(0x33FF6464).value,
        statusColorValue: const Color(0xFFE7000B).value,
        status: 'MENUNGGU RESPON',
      ),
      EmergencyReport(
        id: '2',
        reporterName: 'Siti Aminah',
        reportType: 'Medis Darurat',
        location: 'Perumahan Griya Asri Blok C4',
        timeAgo: '5 menit yang lalu',
        distance: '2.1 km',
        description: 'Warga pingsan mendadak, diduga serangan jantung.',
        iconCodePoint: Icons.medical_services_outlined.codePoint,
        iconBgColorValue: const Color(0x33FFB400).value,
        statusColorValue: const Color(0xFFFFB400).value,
        status: 'BUTUH PENANGANAN',
      ),
      EmergencyReport(
        id: '3',
        reporterName: 'Ahmad Rizki',
        reportType: 'Kebakaran',
        location: 'Jl. Menoreh Tengah X',
        timeAgo: '12 menit yang lalu',
        distance: '4.5 km',
        description: 'Korsleting listrik di tiang gardu.',
        iconCodePoint: Icons.local_fire_department_outlined.codePoint,
        iconBgColorValue: const Color(0x33FF6464).value,
        statusColorValue: const Color(0xFFE7000B).value,
        status: 'TIM MELUNCUR',
      ),
    ];

    for (var report in mockReports) {
      await db.insert('reports', report.toMap());
    }
  }

  Future<List<EmergencyReport>> getReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reports');
    return List.generate(maps.length, (i) {
      return EmergencyReport.fromMap(maps[i]);
    });
  }

  Future<void> insertReport(EmergencyReport report) async {
    final db = await database;
    await db.insert(
      'reports',
      report.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
