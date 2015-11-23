Postfix-based Mail Transport Agent
##################################

Variables
=========

Accepting mail
--------------

* ``mta_is_destination`` (bool): if true, the ``mydestination`` postfix
  parameter will be set to ``$myhostname``. This is required to accept mail
  for local delivery.

* ``mta_alias_maps`` (list of things): map local aliases to user names or pipes
  or remote mail addresses.

  If ``mta_alias_maps`` is false or empty, or ``mta_is_destination`` is false,
  local delivery will be shunted to a ``5.1.1`` error.

  Each thing in the list can have the following attributes:

  * ``thing.file`` (required, string): Path to the file where the alias map is
    stored. Usually, one of the things should be managing ``/etc/aliases``.
  * ``thing.map`` (mapping of addresess to targets): This works like the map in
    ``mta_virtual_maps``.
  * ``thing.owner`` (optional, user name): The UNIX user which will own the
    file. This has semantics with Postfix, namely piped commands will be
    executed under the user and group to which the file belongs, if its not
    UID 0.
  * ``thing.group`` (optional, group name): The UNIX group to which the file
    will belong. See above for details.
  * ``thing.mode`` (optional, chmod-compatible mode specfication): The mode to
    use for the aliases file.

  Note that using a restrictive mode (e.g. no write permissions for the owning
  user) may not properly work, as the postalias command must be able to write
  in the same directory and will do so as the user to which the file belongs.

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

* ``mta_virtual_maps`` (list of things). The things can either be strings, in
  which case they are taken verbatimly in the ``virtual_alias_maps`` parameter
  of postfix. Otherwise, they must be hashes with the following characteristics:

  * ``thing.domain`` (string): The domain for which this mapping shall be used
  * ``thing.map`` (mapping from localparts to strings): The mapping from the
    localpart to the delivery destination. The values may also be lists of
    strings, which will be joined with ``,``.

  Example::

    mta_virtual_maps:
      - domain: foo.example
        map:
          postmaster:
           - fred
           - juliet
          webmaster: root
          sales: sales@bar.example

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

* ``mta_transport_map`` (mapping):  A lookup table, mapping destination
  address patterns to their respective nexthop.  Refer to the `postfix
  transport(5) manual`__ for details on the format of this table.

  __ http://www.postfix.org/transport.5.html

  Example::

    mta_transport_map:
      "example.com": "smtp:server-1.example.com"
      "example.org": "smtp:server-1.example.org"

* ``mta_smtpd_client_restrictions`` (list of strings, default empty):
  Add client restrictions for the server to apply.  See
  `smtpd_client_restrictions`__.

  __ http://www.postfix.org/postconf.5.html#smtpd_client_restrictions

* ``mta_smtpd_helo_required`` (bool, default false):  `smtpd_helo_required`__

  __ http://www.postfix.org/postconf.5.html#smtpd_helo_required

* ``mta_strict_rfc821_envelopes`` (bool, default false): `strict_rfc821_envelopes`__

  __ http://www.postfix.org/postconf.5.html#strict_rfc821_envelopes

* ``mta_smtpd_helo_restrictions`` (list of strings, default empty): Add
  HELO restrictions for the server to apply.  See `smtpd_helo_restrictions`__.

  __ http://www.postfix.org/postconf.5.html#smtpd_helo_restrictions

* ``mta_smtpd_sender_restrictions`` (list of strings, default empty): Add
  sender restrictions for the server to apply.  See `smtpd_sender_restrictions`__.

  __ http://www.postfix.org/postconf.5.html#smtpd_sender_restrictions

* ``mta_smtpd_relay_restrictions`` (list of strings, default
  ``["reject_unauth_destination"]``): Add relay restrictions for the server
  to apply.  See `smtpd_relay_restrictions`__.

  **Note:**  When overriding the default value, make sure to include *at least*
  ``reject_unauth_destination`` in your list of restrictions to prevent your MTA
  from becoming an open relay!

  __ http://www.postfix.org/postconf.5.html#smtpd_relay_restrictions

* ``mta_smtpd_recipient_restrictions`` (list of strings, default empty): Add
  recipient restrictions for the server to apply.  See
  `smtpd_recipient_restrictions`__.

  __ http://www.postfix.org/postconf.5.html#smtpd_recipient_restrictions


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

TLS
---

* ``mta_tls_cert_file`` (string): Path to the TLS certificate
* ``mta_tls_key_file`` (string): Path to the TLS private key
* ``mta_tls_security_level`` (string, default "may"): Value of postfix’s
  `smtpd_tls_security_level`__ directive.

  __ http://www.postfix.org/postconf.5.html#smtpd_tls_security_level

* ``mta_tls_log`` (bool, default false): Enable logging of TLS connections,
  e.g. for cipher statistics

OpenDKIM
--------

If ``mta_dkim`` is not false, the settings below become available and OpenDKIM
will be configured.

* ``mta_dkim_sign`` (bool): Whether the OpenDKIM milter shall sign mail for the
  domains listed in ``mta_dkim_domains``.

* ``mta_dkim_verify`` (bool): Whether the OpenDKIM milter shall verify mail.

* ``mta_dkim_domains`` (list of hashes): Configuration of keys and domains for
  automatic DKIM signing. Each entry must have the following keys:

  * ``name`` (string): The domain name to sign for
  * ``key`` (string): Name part of the key.

  This produces key entries like:

  ``{{ key }}._domainkey.{{ name }}`` and keys must be in
  ``/etc/opendkim/keys/{{ name }}/{{ key }}.private``.

Safety nets and misc
--------------------

* ``mta_soft_bounce`` (bool, default false): if true, ``soft_bounce`` is
  enabled. In that case, postfix will return temporary error codes instead of
  permanent if local delivery fails due to unknown users.

* ``mta_delay_warning`` (string, optional): If set, this is the value of the
  ``delay_warning_time`` setting of postfix.

* ``mta_override_hostname`` (string, optional): If set, this is used as value
  for myhostname instead of the value of ``inventory_hostname``.

* ``mta_message_size_limit`` (number, default 10240000): Maximum size of emails
  that postfix will accept in bytes.

If you’d like to add further files from another role, install them to
``/etc/postfix/aliases.d/`` using file names ending in ``.aliases``, and notify
the ``update include alias file`` handler.  These files will automatically be
concatenated and installed to ``/etc/postfix/aliases``.

Mailman
-------
* ``mta_use_mailman`` (bool, default false):  Set this to enable the mailman
  transport.

* ``mta_mailman_script_location`` (string, default ``/usr/lib/mailman/bin/postfix-to-mailman.py``):
  Location of the ``postfix-to-mailman.py`` program.
