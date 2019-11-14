# -*- coding: utf-8 -*-
from abc import ABCMeta, abstractmethod

from polylogyx.compat import with_metaclass


class AbstractIntelPlugin(with_metaclass(ABCMeta)):
    """
    AbstractAlerterPlugin is the base class for all alerters in PolyLogyx. It
    defines the interface that an alerter should implement in order to support
    sending an alert.
    """
    @abstractmethod
    def analyse_hash(self, entry, node):
        raise NotImplementedError()

    @abstractmethod
    def analyse_domain(self, entry, node):
        raise NotImplementedError()
    @abstractmethod
    def update_credentials(self):
        raise NotImplementedError()
    @abstractmethod
    def generate_alerts(self):
        raise NotImplementedError()