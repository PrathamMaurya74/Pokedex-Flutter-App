import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/pokemon.dart';
import '../models/pokemon_list_response.dart';
import '../models/pokemon_species.dart';

/// Low-level PokéAPI access: builds requests, maps failures to
/// [ApiException] and parses JSON into models. No caching or UI logic.
class PokeApiService {
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Loads the first page, or the page at [pageUrl] (the API's `next` field).
  Future<PokemonListResponse> fetchPokemonList({String? pageUrl}) async {
    final uri = pageUrl != null
        ? Uri.parse(pageUrl)
        : Uri.parse('${ApiConstants.baseUrl}/pokemon').replace(
            queryParameters: {
              'limit': '${ApiConstants.pageSize}',
              'offset': '0',
            },
          );
    final json = await _getJson(uri);
    return _parse(() => PokemonListResponse.fromJson(json));
  }

  /// Loads full details for a Pokémon by ID or name.
  Future<Pokemon> fetchPokemon(String idOrName) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/pokemon/$idOrName');
    final json = await _getJson(uri);
    return _parse(() => Pokemon.fromJson(json));
  }

  /// Loads description, category and gender data for a Pokémon.
  Future<PokemonSpecies> fetchSpecies(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/pokemon-species/$id');
    final json = await _getJson(uri);
    return _parse(() => PokemonSpecies.fromJson(json));
  }

  void dispose() => _client.close();

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(ApiConstants.requestTimeout);
    } on TimeoutException {
      throw const ApiException(ApiErrorType.timeout);
    } on SocketException {
      throw const ApiException(ApiErrorType.network);
    } on http.ClientException {
      throw const ApiException(ApiErrorType.network);
    }

    if (response.statusCode == 404) {
      throw const ApiException(ApiErrorType.notFound, statusCode: 404);
    }
    if (response.statusCode != 200) {
      throw ApiException(ApiErrorType.server, statusCode: response.statusCode);
    }

    final bytes = response.bodyBytes;
    try {
      // Detail responses can be several hundred KB (the moves list), so
      // decode off the UI thread to keep scrolling smooth.
      return await compute(_decodeJson, bytes);
    } on FormatException {
      throw const ApiException(ApiErrorType.parsing);
    }
  }

  /// Turns unexpected JSON shapes into a parsing [ApiException].
  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on TypeError {
      throw const ApiException(ApiErrorType.parsing);
    } on FormatException {
      throw const ApiException(ApiErrorType.parsing);
    }
  }
}

/// Top-level so `compute` can run it in a background isolate.
Map<String, dynamic> _decodeJson(Uint8List bytes) =>
    jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
