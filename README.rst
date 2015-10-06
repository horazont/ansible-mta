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

* ``mta_auto_backup_mx`` (bool): If enabled, postfix will automatically accept
  and relay mail for domains for which it is listed in a MX record (via
  ``permit_mx_backup``).

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


Mail submission agent
---------------------

If ``mta_msa`` is not false, the submission port is opened and the following
settings apply (only for the submission smtpd, not for the regular, port 25,
smtpd):

* If ``mta_msa.sasl`` is not false, sasl is enabled on the submission port and
  the following settings apply:

  * ``mta_msa.sasl.type`` (string): Value for the postfix ``smtpd_sasl_type``
    setting.
  * ``mta_msa.sasl.path`` (string): Value for the postfix ``smtpd_sasl_path``
    setting.

* ``mta_msa.client_restrictions`` (list of strings): List of restrictions to
  apply to clients connecting to the MSA. It is recommended to use::

    - permit_sasl_authenticated
    - reject

  together with ``mta_msa.sasl``.

* ``mta_msa.dkim`` (bool): Enable the OpenDKIM milter for mail submitted via the
  MSA. Requires ``mta_dkim`` to be configured properly.

TLS
---

* ``mta_tls.cert_file`` (string): Path to the TLS certificate
* ``mta_tls.key_file`` (string): Path to the TLS private key
* ``mta_tls.security_level`` (string): Value of postfixs
  ``smtpd_tls_security_level``.
* ``mta_tls.log`` (bool, default false): Enable logging of TLS connections,
  e.g. for cipher statistics

OpenDKIM
--------

If ``mta_dkim`` is not false, OpenDKIM is installed and configured. In that
case, the following settings apply:

* ``mta_dkim.sign`` (bool): Whether the OpenDKIM milter shall sign mail for the
  domains listed in ``mta_dkim.domains``.

* ``mta_dkim.verify`` (bool): Whether the OpenDKIM milter shall verify mail.

* ``mta_dkim.domains`` (list of hashes): Configuration of keys and domains for
  automtaic DKIM signing. Each entry must have the following keys:

  * ``name`` (string): The domain name to sign for
  * ``key`` (string): Name part of the key.

  This produces key entries like:

  ``{{ key }}._domainkey.{{ name }}`` and keys must be in
  ``/etc/opendkim/keys/{{ name }}/{{ key }}.private``.

Safety nets and misc
--------------------

* ``mta_soft_bounce`` (bool): if true, ``soft_bounce`` is enabled. In that case,
  postfix will return temporary error codes instead of permanent if local
  delivery fails due to unknown users.

* ``mta_delay_warning`` (string, optional): If set, this is the value of the
  ``delay_warning_time`` setting of postfix.

* ``mta_override_hostname`` (string, optional): If set, this is used as value
  for myhostname instead of the value of ``inventory_hostname``.
