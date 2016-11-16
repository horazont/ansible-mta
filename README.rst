Postfix-based Mail Transport Agent
##################################

Variables
=========

Accepting mail
--------------

* ``mta_hashes`` (list of things, default empty): a list of hash definitions
  of which the resulting files can be referenced in ``mta_virtual_maps``,
  ``mta_virtual_alias_maps``, ``mta_alias_maps`` and ``mta_transport_maps``.

  Each entry consists of the following fields:

  * ``type`` (string): must be one of the following:

    - ``domain-hash``: hashes of this type require the additional field
      ``domain`` which specifies the domain to append to each entry. This saves
      you from appending ``@domain`` to each entry in ``map`` (see below).

    - ``simple-hash``: hashes of this type simply write out the dictionary
      ``map`` into a file.

    - ``alias-hash``: hashes of this type simply write out the dictionary
      ``map`` into a file, but in aliases format instead of postfix hash format.

  * ``map`` (dictionary): the mapping to write into the hash.
  * ``domain`` (string, only for ``domain-hash``): domain name which is appended
    to each key of the ``map``. The file hash thus looks like ``key@domain
    value``.

  * ``name`` (string, optional if ``path`` is given): a file name for the hash.
    This is relative to ``/etc/postfix/maps``. If ``path`` is given, the
    ``name`` is ignored.

  * ``path`` (string, optional if ``name`` is given): Absolute path for the
    hash. Directories must exist.

* ``mta_ldaps`` (list of things, default empty): a list of ldap_table(5)
  definitions of which the resulting files can be referenced in
  ``mta_virtual_maps``, ``mta_virtual_alias_maps``, ``mta_alias_maps`` and
  ``mta_transport_maps``.

  See the manpage for the meaning of the individual fields.

  Each entry consists of the following fields:

  * ``type`` (string): must be ``ldap``

  * ``servers`` (list of strings, default ``["localhost"]``) -> ldap_table
    ``server_host``
  * ``base`` -> ldap_table ``search_base``
  * ``filter`` -> ldap_table ``query_filter``
  * ``result_attribute`` -> ldap_table ``result_attribute``
  * ``domains`` (list of strings, optional) -> ldap_table ``domain``
  * ``special_result_attribute`` (string, optional) -> ldap_table
    ``special_result_attribute``
  * ``terminal_result_attribute`` (string, optional) -> ldap_table
    ``terminal_result_attribute``
  * ``result_format`` (string, optional) -> ldap_table ``result_format``

  * ``name`` (string, optional if ``path`` is given): a file name for the hash.
    This is relative to ``/etc/postfix/maps``. If ``path`` is given, the
    ``name`` is ignored.

  * ``path`` (string, optional if ``name`` is given): Absolute path for the
    hash. Directories must exist.

* ``mta_virtual_maps`` (list of strings): List of postfix maps, such as
  ``hash:/etc/aliases``. To reference named maps from ``mta_hashes`` or
  ``mta_ldap``, use ``hash:/etc/postfix/maps/$name`` or
  ``ldap:/etc/postfix/maps/$name`` respectively, where ``$name`` must be the
  ``name`` of the hash. If you used ``path``, you simply use the absolute path
  instead of the above.

  This defines the `virtual_mailbox_maps`__.

  __ http://www.postfix.org/postconf.5.html#virtual_mailbox_maps

* ``mta_virtual_alias_maps`` (list of strings): Like ``mta_virtual_maps``, but
  for `virtual_alias_maps`__.

  __ http://www.postfix.org/postconf.5.html#virtual_alias_maps

* ``mta_alias_maps`` (list of strings): Like ``mta_virtual_maps``, but for
  `alias_maps`__.

  __ http://www.postfix.org/postconf.5.html#alias_maps

* ``mta_transport_maps`` (list of strings): Like ``mta_virtual_maps``, but for
  `transport_maps`__.

  __ http://www.postfix.org/postconf.5.html#transport_maps

* ``mta_listen`` (bool, default true): if true, postfix will be configured to
  listen on port 25 for incoming connections.

* ``mta_domains`` (list of strings): the list of domains for which the MTA shall
  accept mail. This is independent from ``mta_is_destination`` -- domains may be
  purely for forwarding purposes.

* ``mta_message_size_limit`` (integer): Maximum size for a message in bytes to
  be accepted for delivery (on either service, smtpd or submission)

* ``mta_postscreen`` (thing or false): If not false, the ``postscreen`` service
  will be enabled.

  In that case:

  * ``mta_postscreen.greet`` (thing or false): If not false, the multipart
    greeting will be used by postscreen.

    In that case:

    * ``mta_postscreen.greet.action`` (string): The action to take when a client
      fails the greet test, see ``postscreen_greet_action`` in the postconf
      manual.
    * ``mta_postscreen.greet.banner`` (string, optional): A custom string for
      the first part of the greet banner. Must contain the hostname as first
      substring, see also ``postscreen_greet_banner`` in the postconf manual.

  * ``mta_postscreen_dnsbl`` (thing or false): If not false, dnsbl checks will
    be enabled. Make sure to have a local caching resolver.

    In that case:

    * ``mta_postscreen.dnsbl.sites`` (list of strings): Postfix DNSBL strings,
      which consist of a hostname and an optional weighting. See
      ``postscreen_dnsbl_sites`` in the postconf manual for details. Note that
      this needs to be a YAML list, not a string with comma separated items.
    * ``mta_postscreen.dnsbl.action`` (string): The action to take when a client
      fails the DNSBL check. See ``postscreen_dnsbl_action``.
    * ``mta_postscreen.dnsbl.threshold`` (integer): The threshold for a client
      to fail the test.

* ``mta_relayhost`` (string):  If set, postfix will relay non-local mail through
  this destination.  Refer to the `postfix documentation on the relayhost
  directive`__ for details.

  __ http://www.postfix.org/postconf.5.html#relayhost

  This setting is useful to achieve a “satellite system” type of setup in which
  all mail is relayed through another server instead of being delivered
  directly; it will typically be used for MTAs that only need to send cron mails
  etc.

* ``mta_relayhost_auth`` (mapping): This is only meaningful if
  ``mta_relayhost`` is set. In that case, this mapping allows to set up
  authentication with the relay host using SASL:

  * ``mta_relayhost_auth.username`` (string): the SASL user name to use
  * ``mta_relayhost_auth.mapfile`` (path): A path where a config file
    containing the credentials will be written to.

* ``mta_relayhost_password`` (string): The password to use for relayhost SASL
  authentication. Required if ``mta_relayhost_auth`` is used.

* ``mta_smtpd_client_restrictions`` (list of strings, default empty):
  Add client restrictions for the server to apply.  See
  `smtpd_client_restrictions`__.

  The restrictions apply only to the MTA service listening on port 25, not the
  MSA. See below for MSA settings.

  __ http://www.postfix.org/postconf.5.html#smtpd_client_restrictions

* ``mta_smtpd_helo_required`` (bool, default false):  `smtpd_helo_required`__

  __ http://www.postfix.org/postconf.5.html#smtpd_helo_required

* ``mta_strict_rfc821_envelopes`` (bool, default false): `strict_rfc821_envelopes`__

  __ http://www.postfix.org/postconf.5.html#strict_rfc821_envelopes

* ``mta_smtpd_helo_restrictions`` (list of strings, default empty): Add
  HELO restrictions for the server to apply.  See `smtpd_helo_restrictions`__.

  The restrictions apply only to the MTA service listening on port 25, not the
  MSA. See below for MSA settings.

  __ http://www.postfix.org/postconf.5.html#smtpd_helo_restrictions

* ``mta_smtpd_sender_restrictions`` (list of strings, default empty): Add
  sender restrictions for the server to apply.  See `smtpd_sender_restrictions`__.

  The restrictions apply only to the MTA service listening on port 25, not the
  MSA. See below for MSA settings.

  __ http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions

* ``mta_smtpd_relay_restrictions`` (list of strings, default
  ``["reject_unauth_destination"]``): Add relay restrictions for the server
  to apply.  See `smtpd_relay_restrictions`__.

  **Note:**  When overriding the default value, make sure to include *at least*
  ``reject_unauth_destination`` in your list of restrictions to prevent your MTA
  from becoming an open relay!

  The restrictions apply only to the MTA service listening on port 25, not the
  MSA. See below for MSA settings.

  __ http://www.postfix.org/postconf.5.html#smtpd_relay_restrictions

* ``mta_smtpd_recipient_restrictions`` (list of strings, default empty): Add
  recipient restrictions for the server to apply.  See
  `smtpd_recipient_restrictions`__.

  The restrictions apply only to the MTA service listening on port 25, not the
  MSA. See below for MSA settings.

  __ http://www.postfix.org/postconf.5.html#smtpd_recipient_restrictions


Spam classification on incoming mail
------------------------------------

If ``mta_spampd`` is not false, ``spampd`` is installed and configured as a
before-queue SMTPD proxy, which acts on all incoming mail on port 25.

Additional configuration is possible with the following options:

* ``mta_spampd_port`` (integer, default 10026): The localhost port on which
  ``spampd`` is configured to listen. Generally, there is no need to change
  this, unless you have something else which needs 10026.

* ``mta_spampd_max_children`` (integer, default 5): The maximum number of
  worker children used by ``spampd``.

* ``mta_spampd_only_local`` (boolean, default true): Whether to disable all
  non-local checks (e.g. DNSBL).

* ``mta_proxy_sink_port`` (integer, default 12500): The sink where ``spampd``
  puts its mail afterwards; this is configured to be a postfix smtpd which will
  then handle the actual (local or remote) delivery.


Local mail delivery
-------------------

Local mail delivery is controlled by the following options.

* ``mta_delivery_type`` (string, default ``"local"``). A string which may have
  any of the following values:

  * ``"local"``: delivery is performed using the ``local(8)``
    transport.
  * ``"lmtp"``: delivery is performed using an LMTP transport depending on the
    ``mta_delivery_agent``.
  * ``"agent_transport"``: delivery is performed using a transport associated
    with the ``mta_delivery_agent`` (see below).

  The key difference is that the ``local(8)`` will use the local, UNIX user
  associated with the recipient (determined by looking up the user name in the
  alias maps), while the ``"agent_transport"`` is fixed to use
  ``mta_agent_transport_user`` permissions.

* ``mta_delivery_agent`` (string or false, default false). A string which may
  have any of the following values:

  * false: Prohibits any delivery and returns a ``5.1.1 Mailbox
    unavailable`` error. This also implicitly forces ``mta_delivery_type`` to
    ``"local"``.

  * ``"dovecot"``: Uses ``dovecot-lda``, passing the recipient address and the
    envelope sender. If used with ``"agent_transport"``, the user name
    resulting from the lookup is also passed.

  .. note::

     For backward compatiblity, ``mta_delivery_agent`` defaults to
     ``"dovecot"`` instead of false if ``mta_is_destination`` is set to true.

* ``mta_agent_transport_user`` (string, default "``vmail:mail``"). This is used
  when agent transport is enabled (see above). It is the POSIX user under which
  the delivery command of the agent is run.

* ``mta_is_destination`` (bool, *deprecated*). If ``mta_delivery_agent`` is not
  set but ``mta_is_destination`` is set to true, ``mta_delivery_agent``
  defaults to ``"dovecot"``.


Mail submission agent
---------------------

If ``mta_msa`` is not false, the submission port is opened and the following
settings apply (only for the submission smtpd, not for the regular, port 25,
smtpd):

* ``mta_msa_sasl_type`` (string): Value for the postfix ``smtpd_sasl_type``
  setting.

* ``mta_msa_sasl_path`` (string): Value for the postfix ``smtpd_sasl_path``
  setting.

Both of the above sasl settings need to be set to enable SASL
authentication. Note that the relay restrictions are configured so that SASL
authentication is required on the submission port to allow sending mail.

* ``mta_msa_dkim`` (bool): Enable the OpenDKIM milter for mail submitted via the
  MSA. Requires ``mta_dkim`` to be configured properly.

* ``mta_msa_privacy`` (bool, default False): if enabled, IPs are removed from
  ``Received`` headers on mail received on the submission port. Several other
  headers are stripped too, which are also configured with
  ``mta_msa_privacy_strip_headers``.

* ``mta_msa_privacy_strip_headers`` (list of strings): if ``mta_msa_privacy`` is
  enabled, the header names in this list are removed from mails received for
  submission. The default list consists of:

  - X-Mailer
  - X-Enigmail
  - X-Originating-Ip
  - User-Agent

* ``mta_msa_sender_restrictions`` (list of strings, default empty): Set
  sender restrictions for the server to apply.  See
  `smtpd_sender_restrictions`__.

  The restrictions apply only to the MSA service.

  __ http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions

* ``mta_msa_recipient_restrictions`` (list of strings, default empty): Set
  recipient restrictions for the server to apply.  See
  `smtpd_recipient_restrictions`__.

  The restrictions apply only to the MSA service.

  __ http://www.postfix.org/postconf.5.html#smtpd_recipient_restrictions

* ``mta_msa_sender_login_maps`` (list of strings): Like ``mta_virtual_maps``,
  but for `sender_login_maps`__.

  The setting applies only to the MSA service.

  __ http://www.postfix.org/postconf.5.html#sender_login_maps

TLS
---

* ``mta_tls_cert_file`` (string): Path to the TLS certificate
* ``mta_tls_key_file`` (string): Path to the TLS private key
* ``mta_tls_security_level`` (string, default "may"): Value of postfix’s
  `smtpd_tls_security_level`__ directive.

  __ http://www.postfix.org/postconf.5.html#smtpd_tls_security_level

* ``mta_tls_log`` (bool, default false): Enable logging of TLS connections,
  e.g. for cipher statistics

Safety nets and misc
--------------------

* ``mta_soft_bounce`` (bool, default false): if true, ``soft_bounce`` is
  enabled. In that case, postfix will return temporary error codes instead of
  permanent if local delivery fails due to unknown users.

* ``mta_delay_warning`` (string, optional): If set, this is the value of the
  ``delay_warning_time`` setting of postfix.

* ``mta_override_hostname`` (string, optional): If set, this is used as value
  for myhostname instead of the value of ``inventory_hostname``.


IPTables based traffic accounting
---------------------------------

When ferm is used (``ferm`` is set to true), the following switches can be used
to enable the generation of no-op iptables rules whose packet and bytes counters
can be used for traffic accounting.

* ``mta_iptables_inbound_accounting`` (bool, default false): Add rules to
  account for traffic to and from the local port 25. This effectively tracks
  inbound SMTP traffic.

* ``mta_iptables_delivery_accounting`` (bool, default false): Add rules to
  account for traffic to and from remote port 25 and 465. This effectively
  tracks outbound SMTP traffic.

  Note that if other applications than postfix are sending outbound mails, that
  traffic will also be caught by these rules.

* ``mta_iptables_submission_accounting`` (bool, default false): Add rules to
  account for traffic to and from the local 587 port. This effectively tracks
  submission SMTP traffic.
