import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import '../data/app_services.dart';
import '../models/app_models.dart';
import '../widgets/common.dart';
import 'student_screens.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SchoolModel?>(
      stream: AppServices.backend.watchCurrentSchool(),
      builder: (context, schoolSnapshot) {
        final school = schoolSnapshot.data;
        return ElimuPage(
          bottomNavigation: const ElimuBottomNavigation(
            currentIndex: 0,
            admin: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Dashboard',
                eyebrow: school?.name ?? 'School administration',
                subtitle: 'Overview of all application information.',
              ),
              const SizedBox(height: 38),
              StreamBuilder<List<ApplicationModel>>(
                stream: AppServices.backend.watchSchoolApplications(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return FirebaseErrorState(error: snapshot.error!);
                  }
                  if (!snapshot.hasData) return const FirebaseLoadingState();
                  return _DashboardContent(applications: snapshot.data!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.applications});

  final List<ApplicationModel> applications;

  @override
  Widget build(BuildContext context) {
    final stats = DashboardStats.fromApplications(applications);
    final metrics = [
      _Metric(
        value: '${stats.total}',
        label: 'Requests',
        icon: Icons.people_outline,
      ),
      _Metric(
        value: '${stats.denied}',
        label: 'Denied',
        icon: Icons.block_outlined,
      ),
      _Metric(
        value: '${stats.approved}',
        label: 'Approved',
        icon: Icons.thumb_up_alt_outlined,
      ),
      _Metric(
        value: '${stats.onHold}',
        label: 'On hold',
        icon: Icons.hourglass_empty,
      ),
    ];
    final recent = applications.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) => _MetricCard(
            metric: metrics[index],
            index: index,
            onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
          ),
        ),
        const SizedBox(height: 34),
        Row(
          children: [
            const Expanded(
              child: Text(
                'New requests',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const AppMenuButton(),
          ],
        ),
        const SizedBox(height: 18),
        if (recent.isEmpty)
          const EmptyState(message: 'No applications have arrived yet.')
        else
          for (var index = 0; index < recent.length; index++) ...[
            _CompactRequestRow(number: index + 1, application: recent[index]),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.index,
    required this.onTap,
  });

  final _Metric metric;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (index) {
      0 => const Color(0xFFB6E98A),
      1 => const Color(0xFFE6F28D),
      2 => const Color(0xFFE4F48B),
      _ => const Color(0xFFAEE584),
    };
    return OutlineCard(
      color: color,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Stack(
        children: [
          Positioned(
            right: -4,
            top: 10,
            child: Icon(
              metric.icon,
              size: 96,
              color: AppColors.ink.withValues(alpha: 0.13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ink.withValues(alpha: 0.72),
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                metric.value,
                style: const TextStyle(
                  fontSize: 42,
                  height: 0.9,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                metric.label,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactRequestRow extends StatelessWidget {
  const _CompactRequestRow({required this.number, required this.application});

  final int number;
  final ApplicationModel application;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 25, child: Text('$number')),
        Expanded(child: _RequestCard(application: application, compact: true)),
      ],
    );
  }
}

class AllRequestsPage extends StatelessWidget {
  const AllRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SchoolModel?>(
      stream: AppServices.backend.watchCurrentSchool(),
      builder: (context, schoolSnapshot) => ElimuPage(
        bottomNavigation: const ElimuBottomNavigation(
          currentIndex: 2,
          admin: true,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'All requests',
              eyebrow: schoolSnapshot.data?.name ?? 'School administration',
              subtitle: 'Review every application submitted to your school.',
            ),
            const SizedBox(height: 38),
            StreamBuilder<List<ApplicationModel>>(
              stream: AppServices.backend.watchSchoolApplications(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return FirebaseErrorState(error: snapshot.error!);
                }
                if (!snapshot.hasData) return const FirebaseLoadingState();
                final applications = snapshot.data!;
                if (applications.isEmpty) {
                  return const EmptyState(
                    message: 'No applications have arrived yet.',
                  );
                }
                return Column(
                  children: [
                    for (
                      var index = 0;
                      index < applications.length;
                      index++
                    ) ...[
                      Row(
                        children: [
                          SizedBox(width: 25, child: Text('${index + 1}')),
                          Expanded(
                            child: _RequestCard(
                              application: applications[index],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  const _RequestCard({required this.application, this.compact = false});

  final ApplicationModel application;
  final bool compact;

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _updating = false;

  Future<void> _setStatus(ApplicationStatus status) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await AppServices.backend.updateApplicationStatus(
        widget.application.id,
        status,
      );
      if (mounted) {
        showElimuMessage(
          context,
          'Application marked ${status.label.toLowerCase()}.',
        );
      }
    } catch (error) {
      if (mounted) showElimuMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Color get _color => switch (widget.application.status) {
    ApplicationStatus.approved => AppColors.leaf.withValues(alpha: 0.36),
    ApplicationStatus.denied => AppColors.coral.withValues(alpha: 0.42),
    ApplicationStatus.onHold => const Color(0xFFE9E48A),
    ApplicationStatus.pending => AppColors.card,
  };

  @override
  Widget build(BuildContext context) {
    return OutlineCard(
      color: _color,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      borderRadius: 18,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 23,
            backgroundColor: Colors.black,
            child: Icon(Icons.person_outline_rounded, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.application.studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.application.educationLevel} · ${widget.application.status.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (!_updating) ...[
            PopupMenuButton<ApplicationStatus>(
              tooltip: 'Change status',
              padding: EdgeInsets.zero,
              iconSize: 18,
              onSelected: _setStatus,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: ApplicationStatus.approved,
                  child: Text('Approve'),
                ),
                PopupMenuItem(
                  value: ApplicationStatus.onHold,
                  child: Text('Put on hold'),
                ),
                PopupMenuItem(
                  value: ApplicationStatus.denied,
                  child: Text('Deny'),
                ),
              ],
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          const SizedBox(width: 4),
          _RequestAction(
            icon: Icons.north_east_rounded,
            color: const Color(0xFF4E574B),
            foreground: Colors.white,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.requestDetails,
              arguments: widget.application.id,
            ),
          ),
        ],
      ),
    );
  }
}

class RequestDetailsPage extends StatelessWidget {
  const RequestDetailsPage({this.applicationId, super.key});

  final String? applicationId;

  @override
  Widget build(BuildContext context) {
    if (applicationId == null || applicationId!.isEmpty) {
      return StreamBuilder<List<ApplicationModel>>(
        stream: AppServices.backend.watchSchoolApplications(),
        builder: (context, snapshot) => _RequestDetailsScaffold(
          application: snapshot.data?.firstOrNull,
          loading: !snapshot.hasData,
          error: snapshot.error,
        ),
      );
    }
    return StreamBuilder<ApplicationModel?>(
      stream: AppServices.backend.watchApplication(applicationId!),
      builder: (context, snapshot) => _RequestDetailsScaffold(
        application: snapshot.data,
        loading: !snapshot.hasData,
        error: snapshot.error,
      ),
    );
  }
}

class _RequestDetailsScaffold extends StatelessWidget {
  const _RequestDetailsScaffold({
    required this.application,
    required this.loading,
    required this.error,
  });

  final ApplicationModel? application;
  final bool loading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(
        currentIndex: 2,
        admin: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Check request',
            eyebrow: application?.schoolName ?? 'School administration',
            subtitle: 'Check whether this application can be approved.',
          ),
          const SizedBox(height: 38),
          if (error != null)
            FirebaseErrorState(error: error!)
          else if (loading)
            const FirebaseLoadingState()
          else if (application == null)
            const EmptyState(message: 'This application is unavailable.')
          else
            _RequestDetailsCard(application: application!),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _RequestDetailsCard extends StatefulWidget {
  const _RequestDetailsCard({required this.application});

  final ApplicationModel application;

  @override
  State<_RequestDetailsCard> createState() => _RequestDetailsCardState();
}

class _RequestDetailsCardState extends State<_RequestDetailsCard> {
  bool _updating = false;

  Future<void> _setStatus(ApplicationStatus status) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await AppServices.backend.updateApplicationStatus(
        widget.application.id,
        status,
      );
      if (mounted) {
        showElimuMessage(
          context,
          'Application marked ${status.label.toLowerCase()}.',
        );
      }
    } catch (error) {
      if (mounted) showElimuMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _openTranscript() async {
    final value = widget.application.transcriptUrl;
    final uri = value == null || value.trim().isEmpty
        ? null
        : Uri.tryParse(value);
    if (uri == null) {
      if (mounted) {
        showElimuMessage(
          context,
          'No transcript was uploaded with this application.',
        );
      }
      return;
    }
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!opened && mounted) {
      showElimuMessage(
        context,
        'The transcript could not be opened. Check your browser permissions.',
      );
    }
  }

  bool get _hasTranscript {
    final value = widget.application.transcriptUrl;
    return value != null && value.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final application = widget.application;
    final details = [
      ('Address', application.studentLocation),
      ('Gender', application.studentGender),
      (
        'Date of birth',
        application.studentDateOfBirth == null
            ? ''
            : formatDate(application.studentDateOfBirth!),
      ),
      ('Education level', application.educationLevel),
      ('Current school', application.currentSchool),
      ('Email', application.studentEmail),
      ('Phone', application.studentPhone),
      ('Submitted', formatDate(application.createdAt)),
      ('Status', application.status.label),
    ];

    final color = switch (application.status) {
      ApplicationStatus.approved => AppColors.leaf.withValues(alpha: 0.28),
      ApplicationStatus.denied => AppColors.coral.withValues(alpha: 0.28),
      ApplicationStatus.onHold => const Color(0x66E9E48A),
      ApplicationStatus.pending => AppColors.card,
    };

    return OutlineCard(
      color: color,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      borderRadius: 25,
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 29,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.studentName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      application.status.label,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (_updating)
                const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                _RequestAction(
                  icon: Icons.close_rounded,
                  color: AppColors.coral,
                  onTap: () => _setStatus(ApplicationStatus.denied),
                ),
                const SizedBox(width: 7),
                _RequestAction(
                  icon: Icons.hourglass_empty_rounded,
                  color: const Color(0xFFE9E48A),
                  onTap: () => _setStatus(ApplicationStatus.onHold),
                ),
                const SizedBox(width: 7),
                _RequestAction(
                  icon: Icons.check_rounded,
                  color: AppColors.leaf,
                  onTap: () => _setStatus(ApplicationStatus.approved),
                ),
              ],
            ],
          ),
          const SizedBox(height: 34),
          for (final item in details) ...[
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(item.$1, style: const TextStyle(fontSize: 12)),
                ),
                const Text(':'),
                const SizedBox(width: 24),
                Expanded(
                  flex: 6,
                  child: Text(
                    item.$2.isEmpty ? 'Not provided' : item.$2,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 29, color: AppColors.muted),
          ],
          Row(
            children: [
              const Expanded(
                child: Text('Transcript', style: TextStyle(fontSize: 12)),
              ),
              SizedBox(
                height: 38,
                child: FilledButton(
                  onPressed: _hasTranscript ? _openTranscript : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _hasTranscript ? 'Open' : 'Not uploaded',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUserProfile?>(
      stream: AppServices.backend.watchCurrentProfile(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        if (profile?.role == UserRole.schoolAdmin) {
          return _AdminAccount(profile: profile!);
        }
        return _StudentAccount(
          profile: profile,
          loading: profileSnapshot.connectionState == ConnectionState.waiting,
          error: profileSnapshot.error,
        );
      },
    );
  }
}

class _AdminAccount extends StatelessWidget {
  const _AdminAccount({required this.profile});

  final AppUserProfile profile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SchoolModel?>(
      stream: AppServices.backend.watchCurrentSchool(),
      builder: (context, snapshot) => ElimuPage(
        bottomNavigation: const ElimuBottomNavigation(
          currentIndex: 4,
          admin: true,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'My account',
              eyebrow: snapshot.data?.name ?? 'School administration',
              subtitle: 'View information about your school account.',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: snapshot.data == null
                    ? null
                    : () => Navigator.pushNamed(context, AppRoutes.editAccount),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit account'),
                style: TextButton.styleFrom(foregroundColor: AppColors.ink),
              ),
            ),
            if (snapshot.hasError)
              FirebaseErrorState(error: snapshot.error!)
            else if (!snapshot.hasData)
              const FirebaseLoadingState()
            else if (snapshot.data == null)
              const EmptyState(
                message: 'No school is connected to this account.',
              )
            else
              _SchoolAccountDetails(
                school: snapshot.data!,
                username: profile.username,
              ),
          ],
        ),
      ),
    );
  }
}

class _SchoolAccountDetails extends StatelessWidget {
  const _SchoolAccountDetails({required this.school, required this.username});

  final SchoolModel school;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoPairCard(
          leftLabel: 'School name',
          leftValue: school.name,
          rightLabel: 'Location',
          rightValue: school.location,
        ),
        const SizedBox(height: 13),
        InfoPairCard(
          leftLabel: 'Available spots',
          leftValue:
              '${school.availableSpots} Spots / ${school.availableSpotsLevel} (${school.availableSpotsClass})',
          rightLabel: 'School fees',
          rightValue: school.formattedFees,
        ),
        const SizedBox(height: 13),
        InfoPairCard(
          leftLabel: 'Sector',
          leftValue: school.sector,
          rightLabel: 'Education stages',
          rightValue: school.educationStages.join(' | '),
        ),
        const SizedBox(height: 13),
        InfoPairCard(
          leftLabel: 'Email',
          leftValue: school.email,
          rightLabel: 'Phone',
          rightValue: school.phone,
        ),
        const SizedBox(height: 13),
        InfoPairCard(
          leftLabel: 'Username',
          leftValue: username,
          rightLabel: 'School level',
          rightValue: school.level,
        ),
        const SizedBox(height: 13),
        OutlineCard(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pictures',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                height: 48,
                child: school.imageUrls.isEmpty
                    ? const Text(
                        'No pictures uploaded',
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: school.imageUrls.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 6),
                        itemBuilder: (context, index) => ClipOval(
                          child: SizedBox.square(
                            dimension: 48,
                            child: SchoolImage(url: school.imageUrls[index]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentAccount extends StatelessWidget {
  const _StudentAccount({
    required this.profile,
    required this.loading,
    required this.error,
  });

  final AppUserProfile? profile;
  final bool loading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'My account',
            eyebrow: profile?.displayName ?? 'Student account',
            subtitle: 'View your ElimuPath account information.',
          ),
          const SizedBox(height: 38),
          if (error != null)
            FirebaseErrorState(error: error!)
          else if (loading)
            const FirebaseLoadingState()
          else if (profile == null)
            const EmptyState(message: 'Sign in to view your account.')
          else ...[
            InfoPairCard(
              leftLabel: 'Name',
              leftValue: profile!.displayName,
              rightLabel: 'Username',
              rightValue: profile!.username,
            ),
            const SizedBox(height: 13),
            InfoPairCard(
              leftLabel: 'Email',
              leftValue: profile!.email,
              rightLabel: 'Phone',
              rightValue: profile!.phone,
            ),
            const SizedBox(height: 13),
            InfoPairCard(
              leftLabel: 'Location',
              leftValue: profile!.location,
              rightLabel: 'Gender',
              rightValue: profile!.gender,
            ),
            const SizedBox(height: 13),
            InfoPairCard(
              leftLabel: 'Education level',
              leftValue: profile!.educationLevel,
              rightLabel: 'Current school',
              rightValue: profile!.currentSchool.isEmpty
                  ? 'Not provided'
                  : profile!.currentSchool,
            ),
          ],
        ],
      ),
    );
  }
}

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _spots = TextEditingController();
  final _fees = TextEditingController();
  final _spotsLevel = TextEditingController();
  final _spotsClass = TextEditingController();
  final _sector = TextEditingController();
  final _level = TextEditingController();
  final _stages = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _picture = TextEditingController();
  SchoolModel? _school;
  UploadData? _newImage;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _location,
      _spots,
      _fees,
      _spotsLevel,
      _spotsClass,
      _sector,
      _level,
      _stages,
      _email,
      _phone,
      _username,
      _password,
      _picture,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fill(SchoolModel school) {
    if (_initialized) return;
    _initialized = true;
    _school = school;
    _name.text = school.name;
    _location.text = school.location;
    _spots.text = '${school.availableSpots}';
    _fees.text = '${school.schoolFees}';
    _spotsLevel.text = school.availableSpotsLevel;
    _spotsClass.text = school.availableSpotsClass;
    _sector.text = school.sector;
    _level.text = school.level;
    _stages.text = school.educationStages.join(', ');
    _email.text = school.email;
    _phone.text = school.phone;
    _username.text = AppServices.backend.cachedProfile?.username ?? '';
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;
    if (file.size > 8 * 1024 * 1024) {
      if (mounted) {
        showElimuMessage(context, 'The school picture must be smaller than 8 MB.');
      }
      return;
    }
    setState(() {
      _newImage = UploadData(
        bytes: file.bytes!,
        fileName: file.name,
        contentType: _imageContentType(file.extension),
      );
      _picture.text = file.name;
    });
  }

  String? _imageContentType(String? extension) {
    return switch (extension?.toLowerCase()) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => null,
    };
  }

  int _number(String value) {
    return int.tryParse(value.replaceAll(RegExp('[^0-9]'), '')) ?? 0;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate() || _school == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      final images = [..._school!.imageUrls];
      var imageUploaded = true;
      if (_newImage != null) {
        try {
          final url = await AppServices.backend
              .uploadSchoolImage(_newImage!)
              .timeout(const Duration(seconds: 10));
          if (url.isNotEmpty) images.add(url);
        } catch (_) {
          // School details can still be saved when optional Storage is down.
          imageUploaded = false;
        }
      }
      final updated = _school!.copyWith(
        name: _name.text.trim(),
        location: _location.text.trim(),
        availableSpots: _number(_spots.text),
        schoolFees: _number(_fees.text),
        availableSpotsLevel: _spotsLevel.text.trim(),
        availableSpotsClass: _spotsClass.text.trim(),
        sector: _sector.text.trim(),
        level: _level.text.trim(),
        educationStages: _stages.text
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        imageUrls: images,
      );
      await AppServices.backend.updateSchool(
        updated,
        username: _username.text.trim(),
        newPassword: _password.text.isEmpty ? null : _password.text,
      );
      if (!mounted) return;
      showElimuMessage(
        context,
        imageUploaded
            ? 'Account information updated.'
            : 'Account updated, but the picture could not be uploaded.',
      );
      Navigator.pushReplacementNamed(context, AppRoutes.account);
    } catch (error) {
      if (mounted) showElimuMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SchoolModel?>(
      stream: AppServices.backend.watchCurrentSchool(),
      builder: (context, snapshot) {
        if (snapshot.data != null) _fill(snapshot.data!);
        return ElimuPage(
          bottomNavigation: const ElimuBottomNavigation(
            currentIndex: 4,
            admin: true,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'Edit account',
                  eyebrow: snapshot.data?.name ?? 'School administration',
                  subtitle: 'Change information about your school account.',
                ),
                const SizedBox(height: 35),
                if (snapshot.hasError)
                  FirebaseErrorState(error: snapshot.error!)
                else if (!snapshot.hasData)
                  const FirebaseLoadingState()
                else if (snapshot.data == null)
                  const EmptyState(
                    message: 'No school is connected to this account.',
                  )
                else ...[
                  _AdminFieldPair(
                    left: ElimuTextField(
                      label: 'School name',
                      controller: _name,
                      validator: requiredField,
                    ),
                    right: ElimuTextField(
                      label: 'Location',
                      controller: _location,
                      validator: requiredField,
                    ),
                  ),
                  const SizedBox(height: 19),
                  _AdminFieldPair(
                    left: ElimuTextField(
                      label: 'Available spots',
                      controller: _spots,
                      keyboardType: TextInputType.number,
                      validator: requiredField,
                    ),
                    right: ElimuTextField(
                      label: 'School fees',
                      controller: _fees,
                      keyboardType: TextInputType.number,
                      validator: requiredField,
                    ),
                  ),
                  const SizedBox(height: 19),
                  _AdminFieldPair(
                    left: ElimuTextField(
                      label: 'Available spots level',
                      controller: _spotsLevel,
                    ),
                    right: ElimuTextField(
                      label: 'Available spots class',
                      controller: _spotsClass,
                    ),
                  ),
                  const SizedBox(height: 19),
                  _AdminFieldPair(
                    left: ElimuTextField(
                      label: 'Sector',
                      controller: _sector,
                      validator: requiredField,
                    ),
                    right: ElimuTextField(
                      label: 'School level',
                      controller: _level,
                      validator: requiredField,
                    ),
                  ),
                  const SizedBox(height: 19),
                  ElimuTextField(
                    label: 'Education stages (comma separated)',
                    controller: _stages,
                    validator: requiredField,
                  ),
                  const SizedBox(height: 19),
                  _AdminFieldPair(
                    left: ElimuTextField(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: emailField,
                    ),
                    right: ElimuTextField(
                      label: 'Phone',
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: requiredField,
                    ),
                  ),
                  const SizedBox(height: 19),
                  _AdminFieldPair(
                    left: ElimuTextField(
                      label: 'Username',
                      controller: _username,
                      validator: requiredField,
                    ),
                    right: ElimuTextField(
                      label: 'New password (optional)',
                      controller: _password,
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? null
                          : passwordField(value),
                    ),
                  ),
                  const SizedBox(height: 19),
                  ElimuTextField(
                    label: 'Add a school picture',
                    controller: _picture,
                    readOnly: true,
                    onTap: _pickImage,
                    suffixIcon: const Icon(
                      Icons.upload_file_outlined,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 25),
                  PrimaryButton(
                    label: _saving ? 'Saving...' : 'Done',
                    onPressed: _save,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminFieldPair extends StatelessWidget {
  const _AdminFieldPair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }
}

class _RequestAction extends StatelessWidget {
  const _RequestAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.foreground = AppColors.ink,
  });

  final IconData icon;
  final Color color;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        fixedSize: const Size(34, 34),
        minimumSize: const Size(34, 34),
        padding: EdgeInsets.zero,
        backgroundColor: color,
        foregroundColor: foreground,
      ),
      icon: Icon(icon, size: 17),
    );
  }
}

class _Metric {
  const _Metric({required this.value, required this.label, required this.icon});

  final String value;
  final String label;
  final IconData icon;
}
