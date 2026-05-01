import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:gradproj/features/user/logic/location_cubit.dart';
import 'package:gradproj/features/user/logic/location_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CaregiverLocationScreen extends StatefulWidget {
  final String token;
  const CaregiverLocationScreen({super.key, required this.token});

  @override
  State<CaregiverLocationScreen> createState() => _CaregiverLocationScreenState();
}

class _CaregiverLocationScreenState extends State<CaregiverLocationScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLatLng = const LatLng(30.0444, 31.2357); // Cairo default

  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().getLastLocation(widget.token);
  }

  void _updateMap(double lat, double lng) {
    setState(() {
      _currentLatLng = LatLng(lat, lng);
    });
    _mapController.move(_currentLatLng, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patient Location',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              context.read<LocationCubit>().getLastLocation(widget.token);
            },
          )
        ],
      ),
      body: BlocConsumer<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state is LocationFetchSuccess) {
            _updateMap(state.location.lat, state.location.lng);
          } else if (state is LocationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final loc = (state is LocationFetchSuccess) ? state.location : null;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLatLng,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.gradproj',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLatLng,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (state is LocationLoading)
                Container(
                  color: Colors.white.withValues(alpha: 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              if (loc != null)
                Positioned(
                  bottom: 30.h,
                  left: 20.w,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on, color: AppColors.primary, size: 28.r),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Last Known Location',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                loc.updatedAt ?? 'Just now',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}

