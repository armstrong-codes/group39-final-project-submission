import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import '../data/app_services.dart';
import '../models/app_models.dart';
import '../widgets/common.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  String _query = '';
  String _level = 'All';

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'For your page'),
          const SizedBox(height: 36),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              hintText: 'Search for a school...',
              prefixIcon: Icon(Icons.search_rounded, size: 21),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (final level in const [
                  'All',
                  'Primary level',
                  'Secondary level',
                ]) ...[
                  _FilterChip(
                    label: level,
                    selected: _level == level,
                    onTap: () => setState(() => _level = level),
                  ),
                  const SizedBox(width: 8),
                ],
                CircleIconButton(
                  icon: Icons.tune_rounded,
                  size: 43,
                  iconSize: 20,
                  onTap: () => showElimuMessage(
                    context,
                    'Use the level filters or search by name and location.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          StreamBuilder<List<SchoolModel>>(
            stream: AppServices.backend.watchSchools(),
            builder: (context, schoolSnapshot) {
              if (schoolSnapshot.hasError) {
                return FirebaseErrorState(error: schoolSnapshot.error!);
              }
              if (!schoolSnapshot.hasData) return const FirebaseLoadingState();

              return StreamBuilder<Set<String>>(
                stream: AppServices.backend.watchFavoriteSchoolIds(),
                initialData: const {},
                builder: (context, favoriteSnapshot) {
                  final favorites = favoriteSnapshot.data ?? const <String>{};
                  final schools = schoolSnapshot.data!
                      .where((school) {
                        final query = _query.trim().toLowerCase();
                        final matchesQuery =
                            query.isEmpty ||
                            school.name.toLowerCase().contains(query) ||
                            school.location.toLowerCase().contains(query) ||
                            school.sector.toLowerCase().contains(query);
                        final matchesLevel =
                            _level == 'All' ||
                            school.level == _level ||
                            school.educationStages.any(
                              (stage) =>
                                  '$stage level'.toLowerCase() ==
                                  _level.toLowerCase(),
                            );
                        return matchesQuery && matchesLevel;
                      })
                      .toList(growable: false);

                  if (schools.isEmpty) {
                    return const EmptyState(
                      message: 'No schools match your search.',
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: schools.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 13,
                          mainAxisSpacing: 13,
                          childAspectRatio: 0.82,
                        ),
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      return _SchoolCard(
                        school: school,
                        favorite: favorites.contains(school.id),
                        onFavoriteTap: () async {
                          try {
                            await AppServices.backend.toggleFavorite(school.id);
                          } catch (error) {
                            if (context.mounted) {
                              showElimuMessage(context, error.toString());
                            }
                          }
                        },
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.schoolDetails,
                          arguments: school.id,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class LikedSchoolsPage extends StatelessWidget {
  const LikedSchoolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Liked schools',
            subtitle: 'Schools you have saved will appear here.',
          ),
          const SizedBox(height: 32),
          StreamBuilder<Set<String>>(
            stream: AppServices.backend.watchFavoriteSchoolIds(),
            initialData: const {},
            builder: (context, favoriteSnapshot) {
              if (favoriteSnapshot.hasError) {
                return FirebaseErrorState(error: favoriteSnapshot.error!);
              }
              final favoriteIds = favoriteSnapshot.data ?? const <String>{};
              if (favoriteIds.isEmpty) {
                return const EmptyState(
                  message: 'Tap the heart on a school to save it here.',
                );
              }
              return StreamBuilder<List<SchoolModel>>(
                stream: AppServices.backend.watchSchools(),
                builder: (context, schoolSnapshot) {
                  if (schoolSnapshot.hasError) {
                    return FirebaseErrorState(error: schoolSnapshot.error!);
                  }
                  if (!schoolSnapshot.hasData) {
                    return const FirebaseLoadingState();
                  }
                  final schools = schoolSnapshot.data!
                      .where((school) => favoriteIds.contains(school.id))
                      .toList(growable: false);
                  if (schools.isEmpty) {
                    return const EmptyState(
                      message: 'Your saved schools are no longer available.',
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: schools.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 13,
                          mainAxisSpacing: 13,
                          childAspectRatio: 0.82,
                        ),
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      return _SchoolCard(
                        school: school,
                        favorite: true,
                        onFavoriteTap: () async {
                          try {
                            await AppServices.backend.toggleFavorite(school.id);
                          } catch (error) {
                            if (context.mounted) {
                              showElimuMessage(context, error.toString());
                            }
                          }
                        },
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.schoolDetails,
                          arguments: school.id,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.black : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ink, width: 0.8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.ink,
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({
    required this.school,
    required this.favorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  final SchoolModel school;
  final bool favorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.ink, width: 0.9),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SchoolImage(url: school.imageUrls.firstOrNull),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 13,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          school.sector,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (school.verified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            size: 11,
                            color: Color(0xFF9EEA72),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 11,
                  top: 10,
                  child: IconButton(
                    onPressed: onFavoriteTap,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.60),
                      foregroundColor: favorite ? Colors.red : Colors.white,
                    ),
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      size: 21,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 12,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.level.replaceAll(' level', ''),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        school.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        school.location,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SchoolDetailsPage extends StatelessWidget {
  const SchoolDetailsPage({this.schoolId, super.key});

  final String? schoolId;

  @override
  Widget build(BuildContext context) {
    if (schoolId == null || schoolId!.isEmpty) {
      return StreamBuilder<List<SchoolModel>>(
        stream: AppServices.backend.watchSchools(),
        builder: (context, snapshot) {
          final school = snapshot.data?.firstOrNull;
          return _SchoolDetailsScaffold(
            school: school,
            loading: !snapshot.hasData,
            error: snapshot.error,
          );
        },
      );
    }

    return StreamBuilder<SchoolModel?>(
      stream: AppServices.backend.watchSchool(schoolId!),
      builder: (context, snapshot) => _SchoolDetailsScaffold(
        school: snapshot.data,
        loading: !snapshot.hasData,
        error: snapshot.error,
      ),
    );
  }
}

class _SchoolDetailsScaffold extends StatelessWidget {
  const _SchoolDetailsScaffold({
    required this.school,
    required this.loading,
    required this.error,
  });

  final SchoolModel? school;
  final bool loading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'School details'),
          const SizedBox(height: 34),
          if (error != null)
            FirebaseErrorState(error: error!)
          else if (loading)
            const FirebaseLoadingState()
          else if (school == null)
            const EmptyState(message: 'This school is unavailable.')
          else
            _SchoolDetailsContent(school: school!),
        ],
      ),
    );
  }
}

class _SchoolDetailsContent extends StatelessWidget {
  const _SchoolDetailsContent({required this.school});

  final SchoolModel school;

  @override
  Widget build(BuildContext context) {
    final images = school.imageUrls.isEmpty
        ? const <String?>[null]
        : school.imageUrls.map<String?>((url) => url).toList();
    return Column(
      children: [
        SizedBox(
          height: 215,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.94),
            itemCount: images.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.ink, width: 0.9),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SchoolImage(url: images[index]),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 25,
                        right: 25,
                        bottom: 22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              school.level,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              school.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            if (school.verified) ...[
                              const SizedBox(height: 5),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: Color(0xFFB9F47C),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Verified school',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            Text(
                              school.location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        InfoPairCard(
          leftLabel: 'School name',
          leftValue: school.name,
          rightLabel: 'Location',
          rightValue: school.location,
        ),
        const SizedBox(height: 14),
        InfoPairCard(
          leftLabel: 'Available spots',
          leftValue:
              '${school.availableSpots} Spots / ${school.availableSpotsLevel}',
          rightLabel: 'School fees',
          rightValue: school.formattedFees,
        ),
        const SizedBox(height: 14),
        InfoPairCard(
          leftLabel: 'Email',
          leftValue: school.email,
          rightLabel: 'Phone',
          rightValue: school.phone,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Apply here!',
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.applicationForm,
            arguments: school.id,
          ),
        ),
      ],
    );
  }
}

class InfoPairCard extends StatelessWidget {
  const InfoPairCard({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    super.key,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return OutlineCard(
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 25),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _InfoCell(label: leftLabel, value: leftValue),
            ),
            const VerticalDivider(
              color: AppColors.ink,
              width: 28,
              thickness: 0.8,
            ),
            Expanded(
              child: _InfoCell(label: rightLabel, value: rightValue),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({this.schoolId, super.key});

  final String? schoolId;

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namesController = TextEditingController();
  final _emailController = TextEditingController();
  final _educationController = TextEditingController();
  final _currentSchoolController = TextEditingController();
  final _transcriptController = TextEditingController();
  UploadData? _transcript;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final profile = AppServices.backend.cachedProfile;
    if (profile != null) {
      _namesController.text = profile.displayName;
      _emailController.text = profile.email;
      _educationController.text = profile.educationLevel;
      _currentSchoolController.text = profile.currentSchool;
    }
  }

  @override
  void dispose() {
    _namesController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _currentSchoolController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _pickTranscript() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;
    if (file.size > 10 * 1024 * 1024) {
      if (mounted) {
        showElimuMessage(context, 'The transcript must be smaller than 10 MB.');
      }
      return;
    }
    setState(() {
      _transcript = UploadData(
        bytes: file.bytes!,
        fileName: file.name,
        contentType: _contentType(file.extension),
      );
      _transcriptController.text = file.name;
    });
  }

  String? _contentType(String? extension) {
    return switch (extension?.toLowerCase()) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      _ => null,
    };
  }

  Future<void> _apply() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    var schoolId = widget.schoolId;
    if (schoolId == null || schoolId.isEmpty) {
      final schools = await AppServices.backend.watchSchools().first;
      schoolId = schools.firstOrNull?.id;
    }
    if (schoolId == null) {
      if (mounted) showElimuMessage(context, 'No school is available.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final transcriptUploaded = await AppServices.backend.submitApplication(
        ApplicationDraft(
          schoolId: schoolId,
          names: _namesController.text,
          email: _emailController.text,
          educationLevel: _educationController.text,
          currentSchool: _currentSchoolController.text,
          transcript: _transcript,
        ),
      );
      if (!mounted) return;
      showElimuMessage(
        context,
        transcriptUploaded
            ? 'Your application has been submitted.'
            : 'Application submitted, but the transcript could not be uploaded.',
      );
      Navigator.pushReplacementNamed(context, AppRoutes.applications);
    } catch (error) {
      if (mounted) showElimuMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Applications form',
              subtitle: 'Fill in this form with the right information.',
            ),
            const SizedBox(height: 42),
            ElimuTextField(
              label: 'Your names',
              controller: _namesController,
              validator: requiredField,
            ),
            const SizedBox(height: 22),
            ElimuTextField(
              label: 'Your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: emailField,
            ),
            const SizedBox(height: 22),
            ElimuTextField(
              label: 'Your education level',
              controller: _educationController,
              validator: requiredField,
            ),
            const SizedBox(height: 22),
            ElimuTextField(
              label: 'Your current school',
              controller: _currentSchoolController,
              validator: requiredField,
            ),
            const SizedBox(height: 22),
            ElimuTextField(
              label: 'Upload your transcript',
              controller: _transcriptController,
              readOnly: true,
              onTap: _pickTranscript,
              suffixIcon: const Icon(Icons.upload_file_outlined, size: 20),
            ),
            const SizedBox(height: 46),
            PrimaryButton(
              label: _isSubmitting ? 'Applying...' : 'Apply',
              onPressed: _apply,
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key});

  Color _statusColor(ApplicationStatus status) {
    return switch (status) {
      ApplicationStatus.approved => const Color(0xFFB7E985),
      ApplicationStatus.denied => const Color(0xFFF3A28E),
      ApplicationStatus.onHold => const Color(0xFFE9E48A),
      ApplicationStatus.pending => const Color(0xD9F3FFE8),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Applications',
            subtitle: 'All your school application will be found here.',
          ),
          const SizedBox(height: 40),
          StreamBuilder<List<ApplicationModel>>(
            stream: AppServices.backend.watchMyApplications(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return FirebaseErrorState(error: snapshot.error!);
              }
              if (!snapshot.hasData) return const FirebaseLoadingState();
              final applications = snapshot.data!;
              if (applications.isEmpty) {
                return const EmptyState(
                  message: 'You have not applied to a school yet.',
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < applications.length; index++) ...[
                    _ApplicationRow(
                      index: index,
                      application: applications[index],
                      color: _statusColor(applications[index].status),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

class _ApplicationRow extends StatelessWidget {
  const _ApplicationRow({
    required this.index,
    required this.application,
    required this.color,
  });

  final int index;
  final ApplicationModel application;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text('${index + 1}', style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: OutlineCard(
            color: color,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderRadius: 18,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.schoolName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${application.status.label} at ${formatDate(application.updatedAt)}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (_) => showElimuMessage(
                    context,
                    'Status: ${application.status.label}',
                  ),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'status', child: Text('View status')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SchoolImage extends StatelessWidget {
  const SchoolImage({this.url, super.key});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Image.asset('assets/images/school.png', fit: BoxFit.cover);
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/school.png', fit: BoxFit.cover),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const ColoredBox(color: AppColors.card),
      errorBuilder: (_, _, _) =>
          Image.asset('assets/images/school.png', fit: BoxFit.cover),
    );
  }
}

class FirebaseLoadingState extends StatelessWidget {
  const FirebaseLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 70),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.ink, strokeWidth: 2),
      ),
    );
  }
}

class FirebaseErrorState extends StatelessWidget {
  const FirebaseErrorState({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 38),
            const SizedBox(height: 12),
            const Text(
              'Unable to load Firebase data',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 7),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
      ),
    );
  }
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
