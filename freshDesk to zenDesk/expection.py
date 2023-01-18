class Exceptions(Exception):
    """BaseException"""

    def __init__(self, err_mess):
        super().__init__(err_mess)


# 請求
class ListFreshdeskCategoriesException(Exceptions):
    """A ListFreshdeskCategoriesException is raised when failed to list categories in Freshdesk."""


class ListFreshdeskFoldersException(Exceptions):
    """A ListFreshdeskFoldersException is raised when failed to list folders in Freshdesk."""


class ListFreshdeskArticlesException(Exceptions):
    """A ListFreshdeskArticlesException is raised when failed to list articles in Freshdesk."""


class PutAttachmentException(Exceptions):
    """A PutAttachmentException is raised when failed to put attachment."""


class CreateZendeskCategoryException(Exceptions):
    """A CreateZendeskCategoryException is raised when failed to create category in Zendesk."""


class CreateZendeskSectionException(Exceptions):
    """A CreateZendeskSectionException is raised when failed to create section in Zendesk."""


class CreateZendeskArticleException(Exceptions):
    """A CreateZendeskArticleException is raised when failed to create article in Zendesk."""


class ListZendeskCategoriesException(Exceptions):
    """A ListZendeskCategoriesException is raised when failed to list categories in Zendesk."""


class ListZendeskSectionsException(Exceptions):
    """A ListZendeskSectionsException is raised when failed to list sections in Zendesk."""


class ListZendeskArticlesException(Exceptions):
    """A ListZendeskArticlesException is raised when failed to list articles in Zendesk."""


class GetFromURLException(Exceptions):
    """A GetFromURLException is raised when failed to get article in Zendesk from url."""


class UpdateZendeskArticleException(Exceptions):
    """An UpdateZendeskArticleException is raised when failed to update article in Zendesk."""


class AssociateAttachmentException(Exceptions):
    """An AssociateAttachmentException is raised when failed to associate attachment."""


class ServerError(Exceptions):
    """A ServerError is raised when server error."""


class AccessDenied(Exceptions):
    """An AccessDenied is raised when http 403 error."""


# 人為
class GetAttachmentException(Exceptions):
    """A GetAttachmentException is raised when you can not get attachment file from url."""


class FindZDNewArticleException(Exceptions):
    """A FindZDNewArticleException is raised when you can not find article in Zendesk."""


class FindZDNewSectionException(Exceptions):
    """A FindZDNewSectionException is raised when you can not find section in Zendesk."""


class FindZDNewCategoryException(Exceptions):
    """A FindZDNewCategoryException is raised when you can not find category in Zendesk."""
