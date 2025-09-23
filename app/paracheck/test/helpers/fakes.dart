// test/helpers/fakes.dart
import 'package:paracheck/models/radar.dart';
import 'package:paracheck/services/flight_repository.dart';
import 'package:paracheck/models/flight.dart';

class FakeRepoOk implements FlightRepository {
  FakeRepoOk(this._flights);
  final List<Flight> _flights;

  @override
  Future<List<Flight>> getAll() async => _flights;

  @override
  Future<void> add(Flight flight) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> finalizeRadar(String id, Radar radar) {
    // TODO: implement finalizeRadar
    throw UnimplementedError();
  }

  @override
  Future<Flight?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<void> removeAt(int index) {
    // TODO: implement removeAt
    throw UnimplementedError();
  }

  @override
  Future<void> replaceAll(List<Flight> flights) {
    // TODO: implement replaceAll
    throw UnimplementedError();
  }
}

class FakeRepoError implements FlightRepository {
  @override
  Future<List<Flight>> getAll() async => throw Exception('Boom');
  
  @override
  Future<void> add(Flight flight) {
    // TODO: implement add
    throw UnimplementedError();
  }
  
  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }
  
  @override
  Future<void> finalizeRadar(String id, Radar radar) {
    // TODO: implement finalizeRadar
    throw UnimplementedError();
  }
  
  @override
  Future<Flight?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }
  
  @override
  Future<void> removeAt(int index) {
    // TODO: implement removeAt
    throw UnimplementedError();
  }
  
  @override
  Future<void> replaceAll(List<Flight> flights) {
    // TODO: implement replaceAll
    throw UnimplementedError();
  }
}
